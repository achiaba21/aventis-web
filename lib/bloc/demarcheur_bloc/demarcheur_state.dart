import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';

abstract class DemarcheurState {
  const DemarcheurState();
}

class DemarcheurInitial extends DemarcheurState {
  const DemarcheurInitial();
}

class DemarcheurLoading extends DemarcheurState {
  const DemarcheurLoading();
}

/// État unique du démarcheur — porte à la fois les appartements partenaires
/// et les réservations référées. Les deux listes sont chargées via des events
/// distincts mais cohabitent dans le même état pour que le dashboard puisse
/// les afficher simultanément sans qu'un load écrase l'autre.
class DemarcheurDataLoaded extends DemarcheurState {
  final List<Appartement> appartements;
  final List<Reservation> reservations;

  const DemarcheurDataLoaded({
    this.appartements = const [],
    this.reservations = const [],
  });

  DemarcheurDataLoaded copyWith({
    List<Appartement>? appartements,
    List<Reservation>? reservations,
  }) {
    return DemarcheurDataLoaded(
      appartements: appartements ?? this.appartements,
      reservations: reservations ?? this.reservations,
    );
  }
}

class DemarcheurReservationCreated extends DemarcheurState {
  final Reservation reservation;

  const DemarcheurReservationCreated(this.reservation);
}

class DemarcheurError extends DemarcheurState {
  final String message;

  const DemarcheurError(this.message);
}
