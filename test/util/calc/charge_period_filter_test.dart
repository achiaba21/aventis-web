import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/util/calc/charge_period_filter.dart';

Charge _c({
  DateTime? datePaiement,
  DateTime? dateEcheance,
  DateTime? dateDebut,
  bool estRecurrent = false,
}) {
  final c = Charge();
  c.datePaiement = datePaiement;
  c.dateEcheance = dateEcheance;
  c.dateDebut = dateDebut;
  c.estRecurrent = estRecurrent;
  return c;
}

void main() {
  group('ChargePeriodFilter.includes', () {
    test('charge sans datePaiement → false (RM8)', () {
      final c = _c(dateEcheance: DateTime(2026, 5, 15));
      expect(
        ChargePeriodFilter.includes(c, year: 2026, month: 5),
        isFalse,
        reason: 'RM8 : non payée = exclue, même si échéance dans la période',
      );
    });

    test('charge récurrente sans aucune date → false (RM8)', () {
      final c = _c(estRecurrent: true);
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });

    test('payée dans le mois ciblé → true', () {
      final c = _c(datePaiement: DateTime(2026, 5, 10));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('payée le 1er du mois → true (borne incluse)', () {
      final c = _c(datePaiement: DateTime(2026, 5, 1));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('payée le dernier jour du mois → true (borne incluse)', () {
      final c = _c(datePaiement: DateTime(2026, 5, 31, 23, 59));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isTrue);
    });

    test('payée un mois différent → false', () {
      final c = _c(datePaiement: DateTime(2026, 4, 28));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });

    test('payée même mois mais année différente → false', () {
      final c = _c(datePaiement: DateTime(2025, 5, 15));
      expect(ChargePeriodFilter.includes(c, year: 2026, month: 5), isFalse);
    });
  });

  group('ChargePeriodFilter.includesInRange', () {
    final q2Start = DateTime(2026, 4, 1);
    final q2End = DateTime(2026, 6, 30, 23, 59);

    test('charge sans datePaiement → false', () {
      final c = _c(dateEcheance: DateTime(2026, 5, 15));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });

    test('payée au milieu du trimestre → true', () {
      final c = _c(datePaiement: DateTime(2026, 5, 10));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isTrue,
      );
    });

    test('payée le jour de début (borne) → true', () {
      final c = _c(datePaiement: DateTime(2026, 4, 1));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isTrue,
      );
    });

    test('payée avant la période → false', () {
      final c = _c(datePaiement: DateTime(2026, 3, 31));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });

    test('payée après la période → false', () {
      final c = _c(datePaiement: DateTime(2026, 7, 1));
      expect(
        ChargePeriodFilter.includesInRange(c, start: q2Start, end: q2End),
        isFalse,
      );
    });
  });
}
