import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Réservation enregistrée manuellement par le proprio pour un client externe
/// (pas dans la base locataires plateforme).
///
/// Mirror de `ReservationManuelle extends Reservation` côté backend.
///
/// Depuis backend 2026-05-18 : 3 champs optionnels permettent de tracer un
/// apporteur d'affaires **hors plateforme** (pas de compte Asfar) qui a référé
/// le client. La commission est tracée pour la compta proprio uniquement —
/// aucun compte Asfar n'est crédité automatiquement (gré à gré).
class ReservationManuelle extends Reservation {
  /// Nom de l'apporteur externe. Null si résa client direct.
  String? demarcheurNomExterne;

  /// Téléphone de l'apporteur externe. Null si non renseigné ou si client direct.
  String? demarcheurTelephoneExterne;

  /// Commission convenue avec l'apporteur (FCFA). 0 ou null si client direct.
  double? montantCommission;

  ReservationManuelle() : super() {
    type = ReservationType.manuelle;
  }

  ReservationManuelle.fromJson(Map<String, dynamic> json)
      : super.fromJsonCommon(json) {
    demarcheurNomExterne = json['demarcheurNomExterne'] as String?;
    demarcheurTelephoneExterne = json['demarcheurTelephoneExterne'] as String?;
    montantCommission = (json['montantCommission'] as num?)?.toDouble();
  }

  /// True si la résa a été apportée par un apporteur externe.
  bool get hasApporteurExterne =>
      (demarcheurNomExterne ?? '').trim().isNotEmpty;

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (demarcheurNomExterne != null) {
      data['demarcheurNomExterne'] = demarcheurNomExterne;
    }
    if (demarcheurTelephoneExterne != null) {
      data['demarcheurTelephoneExterne'] = demarcheurTelephoneExterne;
    }
    if (montantCommission != null) {
      data['montantCommission'] = montantCommission;
    }
    return data;
  }
}
