import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/user/demarcheur.dart';

/// Réservation créée par un démarcheur pour son client.
///
/// Mirror de `ReservationDemarcheur extends Reservation` côté backend.
/// Porte 2 champs supplémentaires :
/// - `demarcheur: Demarcheur?` : le démarcheur source (référeur)
/// - `montantCommission: double?` : montant **libre** (FCFA) proposé par le
///   démarcheur pour cette résa (0 = renonce) ; validé par le proprio à la
///   confirmation. Aucun calcul automatique côté serveur.
class ReservationDemarcheur extends Reservation {
  Demarcheur? demarcheur;
  double? montantCommission;

  ReservationDemarcheur({this.demarcheur, this.montantCommission}) : super() {
    type = ReservationType.demarcheur;
  }

  ReservationDemarcheur.fromJson(Map<String, dynamic> json)
      : super.fromJsonCommon(json) {
    demarcheur = json['demarcheur'] != null
        ? Demarcheur.fromJson(
            Map<String, dynamic>.from(json['demarcheur'] as Map))
        : null;
    montantCommission = (json['montantCommission'] as num?)?.toDouble();
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (demarcheur != null) data['demarcheur'] = demarcheur!.toJson();
    if (montantCommission != null) {
      data['montantCommission'] = montantCommission;
    }
    return data;
  }
}
