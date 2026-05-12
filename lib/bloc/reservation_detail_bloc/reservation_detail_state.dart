import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';

/// État de base du `ReservationDetailBloc`.
///
/// Pattern "keep last known data" : la `reservation` est conservée à travers
/// les transitions d'état pour éviter les flashs UI.
abstract class ReservationDetailState {
  /// Dernière réservation connue (cache ou API).
  final Reservation? reservation;

  /// `true` si la réservation provient du cache et qu'un refresh API est en cours.
  final bool isStale;

  ReservationDetailState({this.reservation, this.isStale = false});
}

class ReservationDetailInitial extends ReservationDetailState {
  ReservationDetailInitial();
}

class ReservationDetailLoading extends ReservationDetailState {
  ReservationDetailLoading({super.reservation, super.isStale});
}

class ReservationDetailLoaded extends ReservationDetailState {
  ReservationDetailLoaded(Reservation reservation, {super.isStale})
      : super(reservation: reservation);
}

class ReservationDetailActionInProgress extends ReservationDetailState {
  final ReservationDetailAction action;
  ReservationDetailActionInProgress(this.action, {super.reservation});
}

class ReservationDetailActionSuccess extends ReservationDetailState {
  final ReservationDetailAction action;
  ReservationDetailActionSuccess(this.action, {super.reservation});
}

class ReservationDetailActionError extends ReservationDetailState {
  final ReservationDetailAction action;
  final String message;
  ReservationDetailActionError(this.action, this.message, {super.reservation});
}

class ReservationDetailError extends ReservationDetailState {
  final String message;
  ReservationDetailError(this.message, {super.reservation});
}
