import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';

/// Extension de classification des `Reservation` pour les agrégateurs
/// financiers du proprio (Dashboard + Finances).
///
/// Règles de comptage **strictes** alignées sur le projet :
/// - `isEncaissed` : `payee + finalisee + terminee` — argent réellement
///   reçu. Compte dans `RevenueHeroCard.amount`, `BeneficeNetHeroCard`,
///   `PnLAggregator.revenue`, `PropertyPerfAggregator`.
/// - `isPipeline` : `confirmee` uniquement — engagement pris, paiement
///   pas encore effectué.
/// - `wasReferredByDemarcheur` : `this is ReservationDemarcheur` (héritage
///   aligné backend `@Inheritance(TABLE_PER_CLASS)`).
/// - `demarcheurCommissionAmount` : montant réel de la commission stocké
///   sur `ReservationDemarcheur.montantCommission` (0 pour les autres types).
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
  bool get wasReferredByDemarcheur => this is ReservationDemarcheur;

  /// Montant de la commission démarcheur convenue pour cette résa.
  /// Retourne 0 pour les résa non-démarcheur. Lit le champ réel du backend
  /// au lieu de recalculer un taux côté Flutter.
  double get demarcheurCommissionAmount {
    final r = this;
    if (r is ReservationDemarcheur) return r.montantCommission ?? 0;
    return 0;
  }

  /// La résa tombe dans le mois `[year, month]` (basé sur la date de début
  /// de séjour).
  bool fallsInMonth(int year, int month) {
    final d = debut;
    return d != null && d.year == year && d.month == month;
  }
}
