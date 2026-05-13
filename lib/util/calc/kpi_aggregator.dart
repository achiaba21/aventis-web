import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/model/ui_only/proprio_kpi.dart';

/// Calcule les 4 KPIs du Dashboard propriétaire (grid 2×2) depuis les
/// appartements + l'historique des réservations.
///
/// KPIs :
/// - **Occupation** : ratio jours occupés / jours du mois courant (× 100)
/// - **ADR moyen** : Average Daily Rate = revenu mois / nuits réservées du mois
/// - **Réservations** : nombre de réservations « comptées » du mois courant
/// - **Note moyenne** : moyenne des `note` de tous les appartements
///
/// Les deltas % vs mois précédent sont calculés de la même façon.
class KpiAggregator {
  KpiAggregator._();

  static List<ProprioKpi> fromData({
    required List<Appartement> appartements,
    required List<Reservation> reservations,
  }) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    final occCurrent = _occupancyPercent(reservations, appartements, currentMonth);
    final occPrev = _occupancyPercent(reservations, appartements, previousMonth);

    final adrCurrent = _averageDailyRate(reservations, currentMonth);
    final adrPrev = _averageDailyRate(reservations, previousMonth);

    final resCurrent = _reservationsCountFor(reservations, currentMonth);
    final resPrev = _reservationsCountFor(reservations, previousMonth);

    final noteAvg = _averageNote(appartements);

    return [
      ProprioKpi(
        label: 'Occupation',
        value: '$occCurrent%',
        deltaPercent: _delta(occCurrent.toDouble(), occPrev.toDouble()),
      ),
      ProprioKpi(
        label: 'ADR moyen',
        value: _kFormat(adrCurrent),
        deltaPercent: _delta(adrCurrent.toDouble(), adrPrev.toDouble()),
      ),
      ProprioKpi(
        label: 'Réservations',
        value: '$resCurrent',
        deltaPercent: _delta(resCurrent.toDouble(), resPrev.toDouble()),
      ),
      ProprioKpi(
        label: 'Note moy.',
        value: noteAvg.toStringAsFixed(2),
        deltaPercent: 0,
      ),
    ];
  }

  static int _delta(double current, double prev) {
    if (prev == 0) return current == 0 ? 0 : 100;
    return (((current - prev) / prev) * 100).round();
  }

  static String _kFormat(int amount) {
    if (amount >= 1000) return '${(amount / 1000).round()}k';
    return '$amount';
  }

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }

  static int _reservationsCountFor(
      List<Reservation> reservations, DateTime month) {
    return reservations
        .where((r) =>
            r.debut != null &&
            r.debut!.year == month.year &&
            r.debut!.month == month.month &&
            _isCounted(r.statut))
        .length;
  }

  static int _occupancyPercent(
      List<Reservation> reservations,
      List<Appartement> appartements,
      DateTime month) {
    if (appartements.isEmpty) return 0;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int totalDaysOccupied = 0;
    for (final r in reservations) {
      if (r.debut == null || r.fin == null) continue;
      if (!_isCounted(r.statut)) continue;
      // Calcule la durée recoupant le mois cible
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final start = r.debut!.isBefore(monthStart) ? monthStart : r.debut!;
      final end = r.fin!.isAfter(monthEnd) ? monthEnd : r.fin!;
      if (end.isBefore(start)) continue;
      totalDaysOccupied += end.difference(start).inDays + 1;
    }
    final totalCapacity = appartements.length * daysInMonth;
    if (totalCapacity == 0) return 0;
    return ((totalDaysOccupied / totalCapacity) * 100).round();
  }

  static int _averageDailyRate(
      List<Reservation> reservations, DateTime month) {
    int totalRevenue = 0;
    int totalNights = 0;
    for (final r in reservations) {
      if (r.debut == null || r.fin == null || r.prix == null) continue;
      if (r.debut!.year != month.year || r.debut!.month != month.month) {
        continue;
      }
      if (!_isCounted(r.statut)) continue;
      final nights = r.fin!.difference(r.debut!).inDays;
      if (nights <= 0) continue;
      totalRevenue += r.prix!.round();
      totalNights += nights;
    }
    if (totalNights == 0) return 0;
    return (totalRevenue / totalNights).round();
  }

  static double _averageNote(List<Appartement> appartements) {
    if (appartements.isEmpty) return 0;
    final sum = appartements.fold<double>(0, (s, a) => s + a.rating);
    return sum / appartements.length;
  }
}
