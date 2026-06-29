import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/model/reservation/reservation.dart';

abstract class ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final ReservationReq reservationReq;

  CreateReservation(this.reservationReq);
}

/// Crée une réservation manuelle (propriétaire)
class CreateManualReservation extends ReservationEvent {
  final ReservationManuelleReq req;

  CreateManualReservation(this.req);
}

class LoadUserReservations extends ReservationEvent {}

class LoadProprietaireReservations extends ReservationEvent {}

/// Rafraîchit la liste depuis le repository (API→Hive→état), en forçant un
/// refetch. [isProprietaire] route vers la liste owner (propriétaire) ou user
/// (locataire) — l'app est mono-rôle, le type d'utilisateur tranche. Passer
/// par le repository garantit que l'état reste un miroir de Hive (source de
/// vérité unique) et n'est pas écrasé par une lecture hors-cache.
class RefreshReservations extends ReservationEvent {
  final bool isProprietaire;

  RefreshReservations({this.isProprietaire = false});
}

class CancelReservation extends ReservationEvent {
  final String reference;
  final String? motif;

  CancelReservation(this.reference, {this.motif});
}

class ConfirmReservation extends ReservationEvent {
  final String reference;

  ConfirmReservation(this.reference);
}

class RefuseReservation extends ReservationEvent {
  final String reference;
  final String? motif;

  RefuseReservation(this.reference, {this.motif});
}

class PayReservation extends ReservationEvent {
  final String reference;

  PayReservation(this.reference);
}

class LoadReservationCode extends ReservationEvent {
  final String reference;

  LoadReservationCode(this.reference);
}

class FinalizeReservation extends ReservationEvent {
  final String secretKey;

  FinalizeReservation(this.secretKey);
}

/// Définir la requête de réservation en cours (brouillon)
class SetReservationReq extends ReservationEvent {
  final ReservationReq? reservationReq;

  SetReservationReq(this.reservationReq);
}

/// Effacer la requête de réservation en cours
class ClearReservationReq extends ReservationEvent {}

/// Effacer toutes les réservations (utilisé lors de la déconnexion)
class ClearAllReservations extends ReservationEvent {}

// ==================== MISE À JOUR DEPUIS API ====================

/// Met à jour l'état avec les données fraîches de l'API (background refresh)
class UpdateReservationsFromApi extends ReservationEvent {
  final List<Reservation> reservations;

  UpdateReservationsFromApi(this.reservations);
}

// ==================== PAGINATION (PERF-02) ====================

/// Charge la page suivante des réservations (support sans câblage UI).
/// Sans backend paginé, la fusion dédoublonnée conclut à la fin de liste
/// dès la première page supplémentaire (comportement neutre).
class LoadMoreReservations extends ReservationEvent {
  final bool isProprietaire;
  LoadMoreReservations({this.isProprietaire = false});
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
class ResetReservationState extends ReservationEvent {}