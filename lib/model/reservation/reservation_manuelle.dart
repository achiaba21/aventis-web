import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Réservation enregistrée manuellement par le proprio pour un client externe
/// (pas dans la base locataires plateforme).
///
/// Mirror de `ReservationManuelle extends Reservation` côté backend. Aucun
/// champ spécifique : les infos client externes (`clientExterneNom`, etc.)
/// sont déjà sur `Reservation` parent.
class ReservationManuelle extends Reservation {
  ReservationManuelle() : super() {
    type = ReservationType.manuelle;
  }

  ReservationManuelle.fromJson(Map<String, dynamic> json)
      : super.fromJsonCommon(json);
}
