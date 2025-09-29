import 'package:web_flutter/model/reservation/reservation.dart';

abstract class ReservationState {}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationCreated extends ReservationState {
  final Reservation reservation;

  ReservationCreated(this.reservation);
}

class ReservationLoaded extends ReservationState {
  final List<Reservation> reservations;

  ReservationLoaded(this.reservations);
}

class ReservationError extends ReservationState {
  final String message;

  ReservationError(this.message);
}

class ReservationCancelled extends ReservationState {
  final int reservationId;

  ReservationCancelled(this.reservationId);
}