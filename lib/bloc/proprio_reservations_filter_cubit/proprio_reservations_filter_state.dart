import 'package:asfar/util/calc/reservation_segment.dart';

/// État du filtre des réservations propriétaire.
///
/// Fortement typé (façon `ComptabiliteFilterState`) : segment actif + bien
/// sélectionné (`appartementId` null = « Tous les biens »).
class ProprioReservationsFilterState {
  /// Segment « par intention » actif.
  final ReservationSegment segment;

  /// Bien sélectionné, ou `null` pour « Tous les biens ».
  final int? appartementId;

  const ProprioReservationsFilterState({
    this.segment = ReservationSegment.aTraiter,
    this.appartementId,
  });

  /// État initial : on atterrit sur « À traiter », tous biens confondus.
  factory ProprioReservationsFilterState.initial() =>
      const ProprioReservationsFilterState();

  ProprioReservationsFilterState copyWith({
    ReservationSegment? segment,
    int? appartementId,
    bool clearAppartement = false,
  }) {
    return ProprioReservationsFilterState(
      segment: segment ?? this.segment,
      appartementId:
          clearAppartement ? null : (appartementId ?? this.appartementId),
    );
  }
}
