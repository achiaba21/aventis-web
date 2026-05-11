import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/ui_only/property_perf.dart';

/// Calcule la performance par bien (`PropertyPerf` V7) pour le Dashboard et
/// le Finances P&L du proprio.
///
/// Pour chaque appartement :
/// - `occupancyRate` : ratio jours occupés / jours du mois courant (0..1)
/// - `monthlyRevenue` : somme des prix des réservations comptées du mois
/// - `deltaPercent` : delta % vs mois précédent
class PropertyPerfAggregator {
  PropertyPerfAggregator._();

  static List<PropertyPerf> compute({
    required List<Appartement> appartements,
    required List<Reservation> reservations,
  }) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    return [
      for (final a in appartements)
        PropertyPerf(
          appartement: a,
          occupancyRate: _occupancyForApart(reservations, a, currentMonth),
          monthlyRevenue: _revenueForApart(reservations, a, currentMonth),
          deltaPercent: _delta(
            _revenueForApart(reservations, a, currentMonth).toDouble(),
            _revenueForApart(reservations, a, previousMonth).toDouble(),
          ),
        ),
    ];
  }

  static int _delta(double current, double prev) {
    if (prev == 0) return current == 0 ? 0 : 100;
    return (((current - prev) / prev) * 100).round();
  }

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }

  static int _revenueForApart(
      List<Reservation> reservations, Appartement a, DateTime month) {
    int total = 0;
    for (final r in reservations) {
      if (r.appart?.id != a.id) continue;
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != month.year || r.debut!.month != month.month) {
        continue;
      }
      if (!_isCounted(r.statut)) continue;
      total += r.prix!.round();
    }
    return total;
  }

  static double _occupancyForApart(
      List<Reservation> reservations, Appartement a, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int daysOccupied = 0;
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    for (final r in reservations) {
      if (r.appart?.id != a.id) continue;
      if (r.debut == null || r.fin == null) continue;
      if (!_isCounted(r.statut)) continue;
      final start = r.debut!.isBefore(monthStart) ? monthStart : r.debut!;
      final end = r.fin!.isAfter(monthEnd) ? monthEnd : r.fin!;
      if (end.isBefore(start)) continue;
      daysOccupied += end.difference(start).inDays + 1;
    }
    if (daysInMonth == 0) return 0;
    return (daysOccupied / daysInMonth).clamp(0.0, 1.0);
  }
}
