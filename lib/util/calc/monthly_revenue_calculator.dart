import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/reservation_finance_extensions.dart';

/// Helpers pour les revenus mensuels du proprio (sparkbar + RevenueHeroCard).
///
/// Utilise l'extension `ReservationFinance` sur `Iterable<Reservation>`
/// pour les calculs de base (encaissé + pipeline). Fournit en plus des
/// helpers spécifiques à la sparkbar (`last6Months`, `average3MonthsEnding`)
/// et au formattage de mois.
///
/// Les méthodes acceptent un `DateTime? targetMonth` (défaut = now). Le mois
/// est extrait de ce paramètre et passé à `FinancePeriod.month`.
class MonthlyRevenueCalculator {
  MonthlyRevenueCalculator._();

  static const _monthsShort = [
    'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];

  static const _monthsFull = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  static String shortLabel(DateTime month) => _monthsShort[month.month - 1];
  static String fullLabel(DateTime month) => _monthsFull[month.month - 1];

  /// Normalise un `DateTime` au 1er jour du mois.
  static DateTime normalize(DateTime d) => DateTime(d.year, d.month, 1);

  /// 6 derniers mois se terminant par `targetMonth` (anciens → cible).
  /// Chaque entrée porte son encaissé ET son pipeline.
  static List<MonthlyRevenue> last6Months(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    return [
      for (var i = 5; i >= 0; i--)
        () {
          final m = DateTime(ref.year, ref.month - i, 1);
          return MonthlyRevenue(
            month: m,
            monthShort: _monthsShort[m.month - 1],
            amount: reservations.sumEncaissedNet(
              period: FinancePeriod.month,
              year: m.year,
              index: m.month - 1,
            ),
            pipeline: reservations.sumPipelineNet(
              period: FinancePeriod.month,
              year: m.year,
              index: m.month - 1,
            ),
          );
        }(),
    ];
  }

  /// Revenu net encaissé d'un mois donné (défaut = mois courant).
  static int revenueFor(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final m = normalize(targetMonth ?? DateTime.now());
    return reservations.sumEncaissedNet(
      period: FinancePeriod.month,
      year: m.year,
      index: m.month - 1,
    );
  }

  /// Revenu net du mois précédant `targetMonth`.
  static int previousRevenue(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    final prev = DateTime(ref.year, ref.month - 1, 1);
    return reservations.sumEncaissedNet(
      period: FinancePeriod.month,
      year: prev.year,
      index: prev.month - 1,
    );
  }

  /// Mois précédant `targetMonth` — utile pour l'eyebrow dynamique.
  static DateTime previousMonth({DateTime? targetMonth}) {
    final ref = normalize(targetMonth ?? DateTime.now());
    return DateTime(ref.year, ref.month - 1, 1);
  }

  /// Delta % entre `targetMonth` et le mois précédent.
  static int deltaPercent(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final cur = revenueFor(reservations, targetMonth: targetMonth);
    final prev = previousRevenue(reservations, targetMonth: targetMonth);
    if (prev == 0) return cur == 0 ? 0 : 100;
    return (((cur - prev) / prev) * 100).round();
  }

  /// Montant pipeline (résa confirmees) d'un mois donné.
  static int pipelineFor(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final m = normalize(targetMonth ?? DateTime.now());
    return reservations.sumPipelineNet(
      period: FinancePeriod.month,
      year: m.year,
      index: m.month - 1,
    );
  }

  /// Moyenne glissante 3 mois se terminant par `targetMonth` (inclus).
  static int average3MonthsEnding(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    int total = 0;
    for (var i = 0; i < 3; i++) {
      final m = DateTime(ref.year, ref.month - i, 1);
      total += reservations.sumEncaissedNet(
        period: FinancePeriod.month,
        year: m.year,
        index: m.month - 1,
      );
    }
    return (total / 3).round();
  }
}
