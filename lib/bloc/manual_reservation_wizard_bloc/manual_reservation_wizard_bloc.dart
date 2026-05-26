import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_event.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/util/calc/manual_reservation_validator.dart';

/// BLoC du wizard de création de réservation manuelle.
///
/// Responsabilité unique : piloter les 3 étapes du wizard, valider chaque
/// transition, déléguer la création API à `ReservationBloc` au step 3.
///
/// **NE FAIT PAS** :
/// - d'appel API direct (passe par `ReservationBloc.CreateManualReservation`)
/// - de persistance Hive (cf. business-spec : pas d'auto-save sur réservations
///   transitoires, le proprio doit pouvoir abandonner sans persister)
///
/// Le wizard observe le résultat via `ReservationCreatedSuccess` /
/// `ReservationCreationFailed`, dispatchés par l'écran wizard depuis un
/// `BlocListener<ReservationBloc>`.
class ManualReservationWizardBloc
    extends Bloc<ManualReservationWizardEvent, ManualReservationWizardState> {
  final ReservationBloc _reservationBloc;

  /// Les plages calendrier de l'annonce (pour la validation des dates au step 1).
  List<CalendarPlage> plages;

  ManualReservationWizardBloc({
    required ReservationBloc reservationBloc,
    this.plages = const [],
  })  : _reservationBloc = reservationBloc,
        super(ManualReservationWizardState.initial()) {
    on<InitManualReservationWizard>(_onInit);
    on<UpdateWizardField>(_onUpdateField);
    on<NextWizardStep>(_onNextStep);
    on<PrevWizardStep>(_onPrevStep);
    on<PublishReservation>(_onPublish);
    on<ReservationCreatedSuccess>(_onCreated);
    on<ReservationCreationFailed>(_onFailed);
  }

  void _onInit(
    InitManualReservationWizard event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    emit(ManualReservationWizardState(
      appartement: event.appartement,
      debut: event.initialDebut,
      fin: event.initialFin,
    ));
  }

  void _onUpdateField(
    UpdateWizardField event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    final updated = _applyField(state, event.field, event.value);
    emit(updated.copyWith(errors: const {}, clearErrorMessage: true));
  }

  void _onNextStep(
    NextWizardStep event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    if (state.currentStep >= state.totalSteps) return;
    final errors = _validateCurrentStep(state);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    emit(state.copyWith(
      currentStep: state.currentStep + 1,
      errors: const {},
      clearErrorMessage: true,
    ));
  }

  void _onPrevStep(
    PrevWizardStep event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    if (state.currentStep <= 1) return;
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  Future<void> _onPublish(
    PublishReservation event,
    Emitter<ManualReservationWizardState> emit,
  ) async {
    // Validation globale avant publication.
    final stepErrors = _validateAllSteps(state);
    if (stepErrors.isNotEmpty) {
      emit(state.copyWith(errors: stepErrors));
      return;
    }
    emit(state.copyWith(isPublishing: true, clearErrorMessage: true));

    final isApporteur = state.source?.requiresApporteurExterne ?? false;
    final req = ReservationManuelleReq(
      appartId: state.appartement!.id!,
      debut: state.debut!,
      duree: state.nbNuits,
      clientNom: state.nomClient!.trim(),
      clientTelephone: state.telephoneClient!.trim(),
      montant: state.totalClient,
      source: state.source,
      moyenPaiement: state.moyenPaiement,
      demarcheurId: state.demarcheurId,
      demarcheurNomExterne:
          isApporteur ? state.apporteurNom?.trim() : null,
      demarcheurTelephoneExterne:
          isApporteur ? state.apporteurTelephone?.trim() : null,
      montantCommission: isApporteur ? state.montantCommission : null,
    );
    _reservationBloc.add(CreateManualReservation(req));
  }

  void _onCreated(
    ReservationCreatedSuccess event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    emit(state.copyWith(
      isPublishing: false,
      created: event.createdReservation as Reservation?,
      currentStep: 3,
      errors: const {},
      clearErrorMessage: true,
    ));
  }

  void _onFailed(
    ReservationCreationFailed event,
    Emitter<ManualReservationWizardState> emit,
  ) {
    emit(state.copyWith(
      isPublishing: false,
      errorMessage: event.message,
    ));
  }

  // ============== Helpers privés ==============

  ManualReservationWizardState _applyField(
    ManualReservationWizardState s,
    String field,
    dynamic value,
  ) {
    switch (field) {
      case 'debut':
        // `copyWith(debut: null)` n'écrase pas la valeur (pattern Dart
        // `value ?? this.value`). On utilise le sentinel `clearDebut` pour
        // remettre explicitement à null (cas reset au 3e tap du wizard step 1).
        final newDebut = value as DateTime?;
        return newDebut == null
            ? s.copyWith(clearDebut: true)
            : s.copyWith(debut: newDebut);
      case 'fin':
        final newFin = value as DateTime?;
        return newFin == null
            ? s.copyWith(clearFin: true)
            : s.copyWith(fin: newFin);
      case 'nomClient':
        return s.copyWith(nomClient: value as String?);
      case 'telephoneClient':
        return s.copyWith(telephoneClient: value as String?);
      case 'source':
        // Changement de source : si on quitte apporteurExterne, on clear
        // les champs apporteur pour éviter une incohérence dans le payload.
        final newSource = value as ReservationManuelleSource?;
        if (newSource != ReservationManuelleSource.apporteurExterne) {
          return s.copyWith(
            source: newSource,
            clearDemarcheurId: true,
            clearApporteurNom: true,
            clearApporteurTelephone: true,
            clearMontantCommission: true,
          );
        }
        return s.copyWith(source: newSource);
      case 'moyenPaiement':
        return s.copyWith(moyenPaiement: value as MoyenPaiement?);
      case 'demarcheurId':
        return s.copyWith(demarcheurId: value as int?);
      case 'apporteurNom':
        return s.copyWith(apporteurNom: value as String?);
      case 'apporteurTelephone':
        return s.copyWith(apporteurTelephone: value as String?);
      case 'montantCommission':
        return s.copyWith(montantCommission: value as double?);
      default:
        return s;
    }
  }

  Map<String, String> _validateCurrentStep(ManualReservationWizardState s) {
    switch (s.currentStep) {
      case 1:
        return ManualReservationValidator.validateDates(
          s.debut,
          s.fin,
          plages,
        ).errors;
      case 2:
        final errors = <String, String>{};
        errors.addAll(ManualReservationValidator.validateClient(
          s.nomClient,
          s.telephoneClient,
        ).errors);
        errors.addAll(ManualReservationValidator.validateSource(
          s.source,
          s.apporteurNom,
        ).errors);
        errors.addAll(
            ManualReservationValidator.validatePaiement(s.moyenPaiement).errors);
        return errors;
      default:
        return const {};
    }
  }

  Map<String, String> _validateAllSteps(ManualReservationWizardState s) {
    final errors = <String, String>{};
    errors.addAll(
        ManualReservationValidator.validateDates(s.debut, s.fin, plages).errors);
    errors.addAll(ManualReservationValidator.validateClient(
      s.nomClient,
      s.telephoneClient,
    ).errors);
    errors.addAll(ManualReservationValidator.validateSource(
      s.source,
      s.apporteurNom,
    ).errors);
    errors.addAll(
        ManualReservationValidator.validatePaiement(s.moyenPaiement).errors);
    return errors;
  }
}
