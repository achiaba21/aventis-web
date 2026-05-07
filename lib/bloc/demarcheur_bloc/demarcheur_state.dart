import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';

abstract class DemarcheurState {}

class DemarcheurInitial extends DemarcheurState {}

class DemarcheurLoading extends DemarcheurState {}

class DemarcheurAppartementsLoaded extends DemarcheurState {
  final List<Appartement> appartements;

  DemarcheurAppartementsLoaded(this.appartements);
}

class DemarcheurReservationsLoaded extends DemarcheurState {
  final List<Reservation> reservations;

  DemarcheurReservationsLoaded(this.reservations);
}

class DemarcheurReservationCreated extends DemarcheurState {
  final Reservation reservation;

  DemarcheurReservationCreated(this.reservation);
}

class DemarcheurError extends DemarcheurState {
  final String message;

  DemarcheurError(this.message);
}
