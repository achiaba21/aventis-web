import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';

/// Calcule les revenus des 6 derniers mois (`Sparkbar` du Dashboard proprio)
/// depuis l'historique des réservations.
///
/// Le mois courant est inclus (last). Si aucune réservation pour un mois, le
/// montant est 0. La dernière barre (mois courant) est marquée `highlight`.
class MonthlyRevenueCalculator {
  MonthlyRevenueCalculator._();

  static const _monthsShort = [
    'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];

  /// Retourne les 6 derniers mois agrégés (anciens → mois courant).
  ///
  /// Une réservation est comptée dans le mois de son `debut` (date de séjour).
  /// Seules les réservations avec un statut "réalisé" (confirmée, payée,
  /// finalisée, terminée) sont sommées.
  static List<MonthlyRevenue> last6Months(List<Reservation> reservations) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      months.add(m);
    }

    return [
      for (var i = 0; i < months.length; i++)
        MonthlyRevenue(
          monthShort: _monthsShort[months[i].month - 1],
          amount: _sumForMonth(reservations, months[i]),
          highlight: i == months.length - 1,
        ),
    ];
  }

  static int _sumForMonth(List<Reservation> reservations, DateTime month) {
    int total = 0;
    for (final r in reservations) {
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != month.year || r.debut!.month != month.month) {
        continue;
      }
      if (!_isCounted(r.statut)) continue;
      total += r.prix!.round();
    }
    return total;
  }

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }

  /// Total des 6 derniers mois (utile pour le `RevenueHeroCard.amount`).
  static int totalLast6Months(List<Reservation> reservations) {
    return last6Months(reservations).fold(0, (s, m) => s + m.amount);
  }

  /// Revenu du mois courant (dernier de la liste).
  static int currentMonth(List<Reservation> reservations) {
    final list = last6Months(reservations);
    return list.isEmpty ? 0 : list.last.amount;
  }

  /// Revenu du mois précédent (avant-dernier).
  static int previousMonth(List<Reservation> reservations) {
    final list = last6Months(reservations);
    return list.length < 2 ? 0 : list[list.length - 2].amount;
  }

  /// Delta % du mois courant vs précédent. Retourne 0 si précédent vaut 0.
  static int deltaPercent(List<Reservation> reservations) {
    final cur = currentMonth(reservations);
    final prev = previousMonth(reservations);
    if (prev == 0) return cur == 0 ? 0 : 100;
    return (((cur - prev) / prev) * 100).round();
  }
}
