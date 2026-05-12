import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Extension de classification des `Reservation` pour les agrégateurs
/// financiers du proprio (Dashboard + Finances).
///
/// Règles de comptage **strictes** alignées sur le projet :
/// - `isEncaissed` : `payee + finalisee + terminee` — argent réellement
///   reçu. Compte dans `RevenueHeroCard.amount`, `BeneficeNetHeroCard`,
///   `PnLAggregator.revenue`, `PropertyPerfAggregator`.
/// - `isPipeline` : `confirmee` uniquement — engagement pris, paiement
///   pas encore effectué. Visible comme « Engagé · X FCFA » côté Dashboard.
/// - `wasReferredByDemarcheur` : la résa a été créée par un démarcheur
///   pour son client (`r.type == ReservationType.demarcheur`) → commission
///   12% à provisionner dans le P&L.
extension ReservationCounted on Reservation {
  /// La résa est dans le revenu encaissé (argent reçu).
  bool get isEncaissed {
    final s = statut;
    return s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }

  /// La résa est dans le pipeline (engagée mais non payée).
  bool get isPipeline => statut == ReservationStatus.confirmee;

  /// La résa a été référencée par un démarcheur.
  bool get wasReferredByDemarcheur => type == ReservationType.demarcheur;

  /// La résa tombe dans le mois `[year, month]` (basé sur la date de début
  /// de séjour).
  bool fallsInMonth(int year, int month) {
    final d = debut;
    return d != null && d.year == year && d.month == month;
  }
}
