import 'package:asfar/model/residence/appart.dart';

/// Événements du wizard de création de réservation manuelle.
abstract class ManualReservationWizardEvent {}

/// Initialise le wizard sur une annonce donnée.
class InitManualReservationWizard extends ManualReservationWizardEvent {
  final Appartement appartement;
  final DateTime? initialDebut;
  final DateTime? initialFin;

  InitManualReservationWizard({
    required this.appartement,
    this.initialDebut,
    this.initialFin,
  });
}

/// Met à jour un champ du brouillon.
///
/// Champs supportés :
/// - `debut`, `fin` : `DateTime?`
/// - `nomClient`, `telephoneClient` : `String?`
/// - `source` : `ReservationManuelleSource?`
/// - `moyenPaiement` : `MoyenPaiement?`
/// - `demarcheurId` : `int?`
class UpdateWizardField extends ManualReservationWizardEvent {
  final String field;
  final dynamic value;

  UpdateWizardField(this.field, this.value);
}

/// Avance d'une étape (avec validation préalable).
class NextWizardStep extends ManualReservationWizardEvent {}

/// Recule d'une étape.
class PrevWizardStep extends ManualReservationWizardEvent {}

/// Lance la publication finale (appel API via `ReservationBloc`).
class PublishReservation extends ManualReservationWizardEvent {}

/// Notifie le wizard que la création est réussie (vient du `ReservationBloc`).
class ReservationCreatedSuccess extends ManualReservationWizardEvent {
  final dynamic createdReservation; // Reservation
  ReservationCreatedSuccess(this.createdReservation);
}

/// Notifie le wizard d'une erreur de création.
class ReservationCreationFailed extends ManualReservationWizardEvent {
  final String message;
  ReservationCreationFailed(this.message);
}
