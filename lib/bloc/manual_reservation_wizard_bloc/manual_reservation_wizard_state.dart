import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';

/// État du wizard de création de réservation manuelle.
///
/// Immuable. Le BLoC émet une nouvelle instance via `copyWith` à chaque
/// changement.
class ManualReservationWizardState {
  final Appartement? appartement;
  final DateTime? debut;
  final DateTime? fin;
  final String? nomClient;
  final String? telephoneClient;
  final ReservationManuelleSource? source;
  final MoyenPaiement? moyenPaiement;
  final int? demarcheurId;
  final String? apporteurNom;
  final String? apporteurTelephone;
  final double? montantCommission;
  final int currentStep;
  final int totalSteps;
  final bool isPublishing;
  final Reservation? created;
  final Map<String, String> errors;
  final String? errorMessage;

  const ManualReservationWizardState({
    this.appartement,
    this.debut,
    this.fin,
    this.nomClient,
    this.telephoneClient,
    this.source,
    this.moyenPaiement,
    this.demarcheurId,
    this.apporteurNom,
    this.apporteurTelephone,
    this.montantCommission,
    this.currentStep = 1,
    this.totalSteps = 3,
    this.isPublishing = false,
    this.created,
    this.errors = const {},
    this.errorMessage,
  });

  factory ManualReservationWizardState.initial() {
    return const ManualReservationWizardState();
  }

  /// Nombre de nuits sélectionnées (fin - debut). 0 si dates incomplètes.
  int get nbNuits {
    if (debut == null || fin == null) return 0;
    final diff = fin!.difference(debut!).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Total client = nb nuits × prix/nuit de l'annonce.
  double get totalClient {
    final prix = appartement?.prix ?? 0;
    return nbNuits * prix;
  }

  /// Montant reçu par le proprio (total - commission saisie pour apporteur).
  /// Pour `clientDirect`, commission = 0 → totalRecuProprio = totalClient.
  double get totalRecuProprio {
    final commission = montantCommission ?? 0;
    return totalClient - commission;
  }

  ManualReservationWizardState copyWith({
    Appartement? appartement,
    DateTime? debut,
    DateTime? fin,
    String? nomClient,
    String? telephoneClient,
    ReservationManuelleSource? source,
    MoyenPaiement? moyenPaiement,
    int? demarcheurId,
    String? apporteurNom,
    String? apporteurTelephone,
    double? montantCommission,
    int? currentStep,
    int? totalSteps,
    bool? isPublishing,
    Reservation? created,
    Map<String, String>? errors,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearCreated = false,
    bool clearDebut = false,
    bool clearFin = false,
    bool clearDemarcheurId = false,
    bool clearApporteurNom = false,
    bool clearApporteurTelephone = false,
    bool clearMontantCommission = false,
  }) {
    return ManualReservationWizardState(
      appartement: appartement ?? this.appartement,
      debut: clearDebut ? null : (debut ?? this.debut),
      fin: clearFin ? null : (fin ?? this.fin),
      nomClient: nomClient ?? this.nomClient,
      telephoneClient: telephoneClient ?? this.telephoneClient,
      source: source ?? this.source,
      moyenPaiement: moyenPaiement ?? this.moyenPaiement,
      demarcheurId:
          clearDemarcheurId ? null : (demarcheurId ?? this.demarcheurId),
      apporteurNom:
          clearApporteurNom ? null : (apporteurNom ?? this.apporteurNom),
      apporteurTelephone: clearApporteurTelephone
          ? null
          : (apporteurTelephone ?? this.apporteurTelephone),
      montantCommission: clearMontantCommission
          ? null
          : (montantCommission ?? this.montantCommission),
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isPublishing: isPublishing ?? this.isPublishing,
      created: clearCreated ? null : (created ?? this.created),
      errors: errors ?? this.errors,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
