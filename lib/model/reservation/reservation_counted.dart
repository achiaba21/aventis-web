import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';

/// Extension de classification des `Reservation` pour les agrégateurs
/// financiers du proprio (Dashboard + Finances).
///
/// Règles de comptage **strictes** alignées sur le projet :
/// - `isEncaissed` : `payee + finalisee + terminee` (plateforme/démarcheur)
///   **OU** `confirmee` pour une `ReservationManuelle` — argent réellement
///   reçu. Compte dans `RevenueHeroCard.amount`, `BeneficeNetHeroCard`,
///   `PnLAggregator.revenue`, `PropertyPerfAggregator`.
/// - `isPipeline` : `confirmee` uniquement pour plateforme/démarcheur —
///   engagement pris, paiement pas encore effectué. Les manuelles confirmées
///   ne sont **pas** en pipeline (déjà encaissées).
/// - `wasReferredByDemarcheur` : `this is ReservationDemarcheur` (héritage
///   aligné backend `@Inheritance(TABLE_PER_CLASS)`).
/// - `demarcheurCommissionAmount` : montant réel de la commission stocké
///   sur `ReservationDemarcheur.montantCommission` (0 pour les autres types).
///
/// **Règle métier manuelle :** une `ReservationManuelle` est créée par le
/// proprio pour un client externe (paiement hors plateforme). Depuis le
/// backend 2026-05-13, elle est créée directement en `FINALISER` (le
/// proprio gère un client externe sans paiement plateforme, donc pas
/// d'étapes intermédiaires). La compatibilité avec l'ancien `CONFIRMER` est
/// conservée ci-dessous pour les résas créées avant cette date.
extension ReservationCounted on Reservation {
  /// La résa est dans le revenu encaissé (argent reçu).
  bool get isEncaissed {
    final s = statut;
    if (isManuelle && s == ReservationStatus.confirmee) return true;
    return s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee;
  }

  /// La résa est dans le pipeline (engagée mais non payée).
  ///
  /// Exclut les manuelles confirmées (déjà encaissées, cf. [isEncaissed]).
  bool get isPipeline =>
      statut == ReservationStatus.confirmee && !isManuelle;

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
