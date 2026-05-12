import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/reservation_finance_extensions.dart';

/// Calcule la performance par bien (`PropertyPerf`) pour le Dashboard et
/// la page Finances P&L du proprio.
///
/// Toutes les agrégations passent par l'extension `ReservationFinance` sur
/// `Iterable<Reservation>` pour garantir la cohérence avec les autres
/// calculators.
class PropertyPerfAggregator {
  PropertyPerfAggregator._();

  static List<PropertyPerf> forPeriod({
    required List<Appartement> appartements,
    required List<Reservation> reservations,
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    final prev = period.previousAnchor(year, index);
    return [
      for (final a in appartements)
        PropertyPerf(
          appartement: a,
          occupancyRate: reservations.occupancyForApart(
            a.id,
            period: period,
            year: year,
            index: index,
          ),
          monthlyRevenue: reservations.sumEncaissedNetForApart(
            a.id,
            period: period,
            year: year,
            index: index,
          ),
          deltaPercent: _delta(
            reservations
                .sumEncaissedNetForApart(
                  a.id,
                  period: period,
                  year: year,
                  index: index,
                )
                .toDouble(),
            reservations
                .sumEncaissedNetForApart(
                  a.id,
                  period: period,
                  year: prev.year,
                  index: prev.index,
                )
                .toDouble(),
          ),
        ),
    ];
  }

  static List<PropertyPerf> compute({
    required List<Appartement> appartements,
    required List<Reservation> reservations,
  }) {
    final now = DateTime.now();
    return forPeriod(
      appartements: appartements,
      reservations: reservations,
      period: FinancePeriod.month,
      year: now.year,
      index: now.month - 1,
    );
  }

  static int _delta(double current, double prev) {
    if (prev == 0) return current == 0 ? 0 : 100;
    return (((current - prev) / prev) * 100).round();
  }
}
