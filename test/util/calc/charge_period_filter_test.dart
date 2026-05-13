import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/util/calc/charge_period_filter.dart';

/// Sémantique post-2026-05-13 : chaque charge en base = un paiement déjà
/// enregistré. Le pivot temporel est `dateDebut` (fallback `createdAt`).
Charge _c({
  DateTime? dateDebut,
  DateTime? dateEcheance,
  DateTime? createdAt,
  bool estRecurrent = false,
}) {
  final c = Charge();
  c.dateDebut = dateDebut;
  c.dateEcheance = dateEcheance;
  c.createdAt = createdAt;
  c.estRecurrent = estRecurrent;
  return c;
}

void main() {
  group('ChargePeriodFilter.includes', () {
    test('charge sans aucune date → false', () {
      final c = _c();
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });

    test('dateDebut dans le mois ciblé → true', () {
      final c = _c(dateDebut: DateTime(2026, 5, 10));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('dateDebut le 1er du mois → true (borne incluse)', () {
      final c = _c(dateDebut: DateTime(2026, 5, 1));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('dateDebut un mois différent → false', () {
      final c = _c(dateDebut: DateTime(2026, 4, 28));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });

    test('dateDebut même mois mais année différente → false', () {
      final c = _c(dateDebut: DateTime(2025, 5, 15));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });

    test('fallback createdAt si dateDebut absente', () {
      final c = _c(createdAt: DateTime(2026, 5, 8));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('dateEcheance seule (récurrente future) ne suffit pas', () {
      final c = _c(
        dateEcheance: DateTime(2026, 5, 15),
        estRecurrent: true,
      );
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });
  });

  group('ChargePeriodFilter.includesInRange', () {
    final q2Start = DateTime(2026, 4, 1);
    final q2End = DateTime(2026, 6, 30, 23, 59);

    test('charge sans dateDebut ni createdAt → false', () {
      final c = _c();
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });

    test('dateDebut au milieu du trimestre → true', () {
      final c = _c(dateDebut: DateTime(2026, 5, 10));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isTrue,
      );
    });

    test('dateDebut le jour de début (borne) → true', () {
      final c = _c(dateDebut: DateTime(2026, 4, 1));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isTrue,
      );
    });

    test('dateDebut avant la période → false', () {
      final c = _c(dateDebut: DateTime(2026, 3, 31));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });

    test('dateDebut après la période → false', () {
      final c = _c(dateDebut: DateTime(2026, 7, 1));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });
  });
}
