import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/repository/charge_repository.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion des charges
///
/// Responsabilité unique: CRUD des charges
/// Les calculs comptables sont délégués à ComptabiliteCalculator
class ChargeBloc extends Bloc<ChargeEvent, ChargeState> {
  final ChargeDataManager _repository = ChargeDataManager();

  ChargeBloc() : super(ChargeInitial()) {
    on<LoadCharges>(_onLoadCharges);
    on<RefreshCharges>(_onRefreshCharges);
    on<AddCharge>(_onAddCharge);
    on<UpdateCharge>(_onUpdateCharge);
    on<DeleteCharge>(_onDeleteCharge);
    on<MarkChargeAsPaid>(_onMarkAsPaid);
    on<ResetChargeState>(_onResetChargeState);
  }

  /// Injecter les appartements depuis AppartementBloc.
  /// Nécessaire pour récupérer les infos d'appartement en mode offline.
  void setAppartements(List<Appartement> appartements) {
    _repository.setAppartements(appartements);
    deboger(['[ChargeBloc] Appartements injectés: ${appartements.length}']);
  }

  Future<void> _onLoadCharges(
    LoadCharges event,
    Emitter<ChargeState> emit,
  ) async {
    emit(ChargeLoading());
    try {
      final charges = await _repository.getCharges(
        residenceId: event.residenceId,
        appartementId: event.appartementId,
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
      );

      emit(ChargeLoaded(
        charges: charges,
        residenceId: event.residenceId,
        appartementId: event.appartementId,
        dateDebut: event.dateDebut,
        dateFin: event.dateFin,
      ));
    } catch (e) {
      deboger(['[ChargeBloc] Erreur LoadCharges: $e']);
      emit(ChargeError(message: 'Erreur lors du chargement: $e'));
    }
  }

  Future<void> _onRefreshCharges(
    RefreshCharges event,
    Emitter<ChargeState> emit,
  ) async {
    if (state is ChargeLoaded) {
      final currentState = state as ChargeLoaded;
      add(LoadCharges(
        residenceId: currentState.residenceId,
        appartementId: currentState.appartementId,
        dateDebut: currentState.dateDebut,
        dateFin: currentState.dateFin,
      ));
    } else {
      add(LoadCharges());
    }
  }

  Future<void> _onAddCharge(
    AddCharge event,
    Emitter<ChargeState> emit,
  ) async {
    if (state is! ChargeLoaded) return;

    final currentState = state as ChargeLoaded;
    emit(ChargeLoading());

    try {
      await _repository.createCharge(
        appartementId: event.appartementId,
        typeCharge: event.typeCharge,
        libelle: event.libelle,
        montant: event.montant,
        frequence: event.frequence,
        dateDebut: event.dateDebut,
        dateEcheance: event.dateEcheance,
        estRecurrent: event.estRecurrent,
        notes: event.notes,
      );

      emit(ChargeOperationSuccess(
        message: 'Charge ajoutée avec succès',
        previousState: currentState,
      ));

      // Recharger les données
      add(LoadCharges(
        residenceId: currentState.residenceId,
        appartementId: currentState.appartementId,
        dateDebut: currentState.dateDebut,
        dateFin: currentState.dateFin,
      ));
    } catch (e) {
      deboger(['[ChargeBloc] Erreur AddCharge: $e']);
      emit(ChargeError(message: 'Erreur lors de l\'ajout: $e'));
    }
  }

  Future<void> _onUpdateCharge(
    UpdateCharge event,
    Emitter<ChargeState> emit,
  ) async {
    if (state is! ChargeLoaded) return;

    final currentState = state as ChargeLoaded;
    emit(ChargeLoading());

    try {
      await _repository.updateCharge(event.charge);

      emit(ChargeOperationSuccess(
        message: 'Charge modifiée avec succès',
        previousState: currentState,
      ));

      // Recharger les données
      add(LoadCharges(
        residenceId: currentState.residenceId,
        appartementId: currentState.appartementId,
        dateDebut: currentState.dateDebut,
        dateFin: currentState.dateFin,
      ));
    } catch (e) {
      deboger(['[ChargeBloc] Erreur UpdateCharge: $e']);
      emit(ChargeError(message: 'Erreur lors de la modification: $e'));
    }
  }

  Future<void> _onDeleteCharge(
    DeleteCharge event,
    Emitter<ChargeState> emit,
  ) async {
    if (state is! ChargeLoaded) return;

    final currentState = state as ChargeLoaded;
    emit(ChargeLoading());

    try {
      await _repository.deleteCharge(event.chargeId);

      emit(ChargeOperationSuccess(
        message: 'Charge supprimée avec succès',
        previousState: currentState,
      ));

      // Recharger les données
      add(LoadCharges(
        residenceId: currentState.residenceId,
        appartementId: currentState.appartementId,
        dateDebut: currentState.dateDebut,
        dateFin: currentState.dateFin,
      ));
    } catch (e) {
      deboger(['[ChargeBloc] Erreur DeleteCharge: $e']);
      emit(ChargeError(message: 'Erreur lors de la suppression: $e'));
    }
  }

  Future<void> _onMarkAsPaid(
    MarkChargeAsPaid event,
    Emitter<ChargeState> emit,
  ) async {
    if (state is! ChargeLoaded) return;

    final currentState = state as ChargeLoaded;

    try {
      await _repository.markAsPaid(
        event.chargeId,
        datePaiement: event.datePaiement ?? DateTime.now(),
      );

      // Recharger les données
      add(LoadCharges(
        residenceId: currentState.residenceId,
        appartementId: currentState.appartementId,
        dateDebut: currentState.dateDebut,
        dateFin: currentState.dateFin,
      ));
    } catch (e) {
      deboger(['[ChargeBloc] Erreur MarkAsPaid: $e']);
      emit(ChargeError(message: 'Erreur lors du marquage: $e'));
    }
  }

  // ==================== RÉINITIALISATION ====================

  void _onResetChargeState(
    ResetChargeState event,
    Emitter<ChargeState> emit,
  ) {
    deboger(['[ChargeBloc] Réinitialisation à l\'état Initial']);
    emit(ChargeInitial());
  }
}
