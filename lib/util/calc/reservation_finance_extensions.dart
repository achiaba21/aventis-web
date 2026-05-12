import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';
import 'package:asfar/util/calc/finance_period.dart';

/// Helpers d'agrégation financière sur une collection de `Reservation`.
///
/// Unifie les 4 calculators du proprio (`MonthlyRevenue`, `PnL`,
/// `PropertyPerf`, `Projection`) autour d'une seule API :
/// - **net** = `prix - frais` (frais Asfar soustraits)
/// - **encaissé** = statuts `payee + finalisee + terminee`
/// - **pipeline** = statut `confirmee` uniquement
///
/// Tous les filtres temporels passent par `FinancePeriod` pour garantir la
/// cohérence Dashboard ↔ Finances.
extension ReservationFinance on Iterable<Reservation> {
  /// Somme nette des résa encaissées tombant dans la période donnée.
  int sumEncaissedNet({
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    return _sumNetWhere(
      (r) =>
          r.isEncaissed &&
          r.debut != null &&
          period.contains(year, index, r.debut!),
    );
  }

  /// Somme nette des résa en pipeline (confirmees non encore payées)
  /// tombant dans la période donnée.
  int sumPipelineNet({
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    return _sumNetWhere(
      (r) =>
          r.isPipeline &&
          r.debut != null &&
          period.contains(year, index, r.debut!),
    );
  }

  /// Somme nette des résa encaissées d'un appart spécifique sur la période.
  int sumEncaissedNetForApart(
    int? apartId, {
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    if (apartId == null) return 0;
    return _sumNetWhere(
      (r) =>
          r.appart?.id == apartId &&
          r.isEncaissed &&
          r.debut != null &&
          period.contains(year, index, r.debut!),
    );
  }

  /// Somme nette des résa encaissées **et référées par un démarcheur**
  /// (utile pour la commission démarcheur du P&L).
  int sumEncaissedNetReferred({
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    return _sumNetWhere(
      (r) =>
          r.isEncaissed &&
          r.wasReferredByDemarcheur &&
          r.debut != null &&
          period.contains(year, index, r.debut!),
    );
  }

  /// Nombre de nuits cumulées sur les résa encaissées de la période.
  int sumEncaissedNightsIn({
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    int nights = 0;
    for (final r in this) {
      if (!r.isEncaissed) continue;
      if (r.debut == null || r.fin == null) continue;
      if (!period.contains(year, index, r.debut!)) continue;
      final n = r.fin!.difference(r.debut!).inDays;
      if (n > 0) nights += n;
    }
    return nights;
  }

  /// Taux d'occupation d'un appart sur la période (jours occupés / jours
  /// totaux de la période, clampé entre 0.0 et 1.0).
  double occupancyForApart(
    int? apartId, {
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    if (apartId == null) return 0;
    final start = period.startOf(year, index);
    final end = period.endOf(year, index);
    final totalDays = end.difference(start).inDays + 1;
    if (totalDays == 0) return 0;
    int occupied = 0;
    for (final r in this) {
      if (r.appart?.id != apartId) continue;
      if (r.debut == null || r.fin == null) continue;
      if (!r.isEncaissed) continue;
      final s = r.debut!.isBefore(start) ? start : r.debut!;
      final e = r.fin!.isAfter(end) ? end : r.fin!;
      if (e.isBefore(s)) continue;
      occupied += e.difference(s).inDays + 1;
    }
    return (occupied / totalDays).clamp(0.0, 1.0);
  }

  int _sumNetWhere(bool Function(Reservation) test) {
    int total = 0;
    for (final r in this) {
      if (r.prix == null) continue;
      if (!test(r)) continue;
      final brut = r.prix!.round();
      final frais = (r.frais ?? 0).round();
      total += (brut - frais);
    }
    return total;
  }
}
