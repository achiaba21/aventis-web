import 'package:web_flutter/model/request/reservation_req.dart';

abstract class ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final ReservationReq reservationReq;

  CreateReservation(this.reservationReq);
}

class LoadUserReservations extends ReservationEvent {}

class RefreshReservations extends ReservationEvent {}

class CancelReservation extends ReservationEvent {
  final int reservationId;

  CancelReservation(this.reservationId);
}