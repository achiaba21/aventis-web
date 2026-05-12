import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';

/// Événements du `ReservationDetailBloc`.
abstract class ReservationDetailEvent {}

/// Initialise le BLoC avec une réservation déjà en mémoire (cache instantané).
class LoadFromObject extends ReservationDetailEvent {
  final Reservation reservation;
  LoadFromObject(this.reservation);
}

/// Initialise le BLoC par référence (deep-link push notif, card chat).
class LoadByReference extends ReservationDetailEvent {
  final String reference;
  LoadByReference(this.reference);
}

/// Rafraîchit depuis l'API la réservation courante.
class RefreshFromApi extends ReservationDetailEvent {}

/// Exécute une action sur la réservation courante.
///
/// Le payload contient les paramètres optionnels :
/// - `motif: String` pour `cancel` et `refuse`
/// - `secretKey: String` pour finalize (post-scan)
/// - `editReq: ReservationManuelleReq` pour `edit`
class PerformAction extends ReservationDetailEvent {
  final ReservationDetailAction action;
  final String? motif;
  final String? secretKey;
  final ReservationManuelleReq? editReq;

  PerformAction(
    this.action, {
    this.motif,
    this.secretKey,
    this.editReq,
  });
}

/// Met à jour silencieusement l'état avec la réservation fraîche reçue de l'API.
class UpdateFromApi extends ReservationDetailEvent {
  final Reservation reservation;
  UpdateFromApi(this.reservation);
}
