import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Réservation créée par un locataire via la plateforme.
///
/// Mirror de `ReservationPlateforme extends Reservation` côté backend.
/// Aucun champ spécifique : juste un marker de type `PLATEFORME`.
class ReservationPlateforme extends Reservation {
  ReservationPlateforme() : super() {
    type = ReservationType.plateforme;
  }

  ReservationPlateforme.fromJson(Map<String, dynamic> json)
      : super.fromJsonCommon(json);
}
