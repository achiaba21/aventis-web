import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/projection_point.dart';
import 'package:asfar/util/calc/monthly_revenue_calculator.dart';

/// Calcule les 7 points du line chart « Projection 3 mois »
/// (`ProprioFinancesScreen::ProjectionChart`) depuis l'historique des
/// réservations.
///
/// Composition : 3 mois passés + mois courant + 3 mois futurs (extrapolation).
/// L'extrapolation utilise la moyenne des 3 derniers mois × 3 (rythme stable
/// par défaut). Le mois courant est marqué `isCurrent: true` (marker accent
/// + ligne verticale séparateur passé/futur).
class ProjectionCalculator {
  ProjectionCalculator._();

  static const _monthsShort = [
    'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];

  static List<ProjectionPoint> sevenMonths(List<Reservation> reservations) {
    final now = DateTime.now();
    final points = <ProjectionPoint>[];
    final past = <int>[];

    // 3 mois passés + mois courant
    for (var offset = 3; offset >= 0; offset--) {
      final m = DateTime(now.year, now.month - offset, 1);
      final amount = _sumForMonth(reservations, m);
      past.add(amount);
      points.add(ProjectionPoint(
        monthShort: _monthsShort[m.month - 1],
        amount: amount,
        isProjection: false,
        isCurrent: offset == 0,
      ));
    }

    // 3 mois futurs : extrapolation = moyenne des 3 derniers mois passés
    final avgRecent = past.length >= 3
        ? (past[past.length - 3] + past[past.length - 2] + past.last) ~/ 3
        : (past.isEmpty ? 0 : past.last);

    for (var offset = 1; offset <= 3; offset++) {
      final m = DateTime(now.year, now.month + offset, 1);
      points.add(ProjectionPoint(
        monthShort: _monthsShort[m.month - 1],
        amount: avgRecent,
        isProjection: true,
      ));
    }

    return points;
  }

  static int q1Estimation(List<Reservation> reservations) {
    final points = sevenMonths(reservations);
    return points.where((p) => p.isProjection).fold(0, (s, p) => s + p.amount);
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

  /// Indice du mois courant dans la liste (utile pour le marker + ligne
  /// verticale du chart). Toujours 3 dans cette implémentation (3 passés +
  /// courant à index 3).
  static int currentIndex(List<ProjectionPoint> points) {
    final i = points.indexWhere((p) => p.isCurrent);
    return i < 0 ? 0 : i;
  }
}

/// Helper du module pour ne pas dupliquer la fonction `_sumForMonth` partout.
extension ReservationsMonthlySum on List<Reservation> {
  /// Total revenu pour le mois donné (utilise `MonthlyRevenueCalculator`
  /// indirectement via la méthode publique `currentMonth`).
  int sumForCurrentMonth() => MonthlyRevenueCalculator.currentMonth(this);
}
