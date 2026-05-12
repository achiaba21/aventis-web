import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/projection_point.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/reservation_finance_extensions.dart';

/// Calcule les 7 points du line chart « Projection 3 mois »
/// (`ProprioFinancesScreen::ProjectionChart`) depuis l'historique des
/// réservations.
///
/// Composition : 3 mois passés + mois courant + 3 mois futurs (extrapolation).
/// L'extrapolation utilise la moyenne des 3 derniers mois (rythme stable
/// par défaut). Le mois courant est marqué `isCurrent: true`.
///
/// Utilise `ReservationFinance.sumEncaissedNet` pour la cohérence stricte
/// avec les autres agrégateurs.
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

    for (var offset = 3; offset >= 0; offset--) {
      final m = DateTime(now.year, now.month - offset, 1);
      final amount = reservations.sumEncaissedNet(
        period: FinancePeriod.month,
        year: m.year,
        index: m.month - 1,
      );
      past.add(amount);
      points.add(ProjectionPoint(
        monthShort: _monthsShort[m.month - 1],
        amount: amount,
        isProjection: false,
        isCurrent: offset == 0,
      ));
    }

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

  static int currentIndex(List<ProjectionPoint> points) {
    final i = points.indexWhere((p) => p.isCurrent);
    return i < 0 ? 0 : i;
  }
}
