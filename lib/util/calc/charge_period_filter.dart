import 'package:asfar/model/comptabilite/charge.dart';

/// Règle UNIQUE de filtre temporel des charges (RM8).
///
/// Une charge tombe dans une période si et seulement si son `datePaiement`
/// est dans cette période. Une charge non payée (`datePaiement == null`) n'est
/// jamais incluse dans le P&L ni dans le Cashflow.
///
/// Source unique de vérité utilisée par `PnLAggregator` et
/// `CashflowAggregator` pour garantir la cohérence des chiffres financiers
/// (revenu net = revenus encaissés - charges effectivement payées).
class ChargePeriodFilter {
  ChargePeriodFilter._();

  /// `true` si la charge a été payée dans le mois `[year, month]`.
  static bool includes(
    Charge c, {
    required int year,
    required int month,
  }) {
    final dp = c.datePaiement;
    if (dp == null) return false;
    return dp.year == year && dp.month == month;
  }

  /// `true` si la charge a été payée entre `start` (inclus) et `end` (inclus).
  ///
  /// Utile pour les périodes multi-mois (trimestre/semestre/année).
  static bool includesInRange(
    Charge c, {
    required DateTime start,
    required DateTime end,
  }) {
    final dp = c.datePaiement;
    if (dp == null) return false;
    return !dp.isBefore(start) && !dp.isAfter(end);
  }
}
