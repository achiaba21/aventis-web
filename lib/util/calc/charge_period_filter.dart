import 'package:asfar/model/comptabilite/charge.dart';

/// Règle UNIQUE de filtre temporel des charges (RM8).
///
/// Sémantique post-2026-05-13 : chaque charge en base = un paiement déjà
/// enregistré. Le pivot temporel est désormais `dateDebut` (date à laquelle
/// le paiement a été effectué). Si `dateDebut` est absent, fallback sur
/// `createdAt` (date d'enregistrement côté serveur).
///
/// Source unique de vérité utilisée par `PnLAggregator` et
/// `CashflowAggregator` pour garantir la cohérence des chiffres financiers.
class ChargePeriodFilter {
  ChargePeriodFilter._();

  /// `true` si la charge a été enregistrée dans le mois `[year, month]`.
  static bool includes(
    Charge c, {
    required int year,
    required int month,
  }) {
    final pivot = c.dateDebut ?? c.createdAt;
    if (pivot == null) return false;
    return pivot.year == year && pivot.month == month;
  }

  /// `true` si la charge a été enregistrée entre `start` (inclus) et
  /// `end` (inclus).
  ///
  /// Utile pour les périodes multi-mois (trimestre/semestre/année).
  static bool includesInRange(
    Charge c, {
    required DateTime start,
    required DateTime end,
  }) {
    final pivot = c.dateDebut ?? c.createdAt;
    if (pivot == null) return false;
    return !pivot.isBefore(start) && !pivot.isAfter(end);
  }
}
