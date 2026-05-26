import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/util/calc/manque_a_gagner_calculator.dart';

CalendarPlage _plage({
  required DateTime debut,
  required DateTime fin,
  required PlageStatut statut,
}) {
  return CalendarPlage(
    debut: debut,
    fin: fin,
    statut: statut,
    type: PlageType.reservation,
  );
}

void main() {
  group('ManqueAGagnerCalculator.computeForMonth', () {
    test('aucune plage → manque = jours du mois × prix', () {
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: const [],
        prixNuit: 50000,
        year: 2026,
        month: 5,
      );
      // Mai 2026 = 31 jours
      expect(result, 31 * 50000);
    });

    test('un mois plein occupé → 0', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 1),
          fin: DateTime(2026, 6, 1),
          statut: PlageStatut.occupe,
        ),
      ];
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: plages,
        prixNuit: 50000,
        year: 2026,
        month: 5,
      );
      expect(result, 0);
    });

    test('plage disponible (blocage proprio) compte comme manque à gagner', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 10),
          fin: DateTime(2026, 5, 15),
          statut: PlageStatut.disponible, // blocage
        ),
      ];
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: plages,
        prixNuit: 10000,
        year: 2026,
        month: 5,
      );
      // 31 jours - 0 occupé = 31 jours potentiels (les blocages comptent comme libres)
      expect(result, 31 * 10000);
    });

    test('plage en attente compte comme occupée', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 10),
          fin: DateTime(2026, 5, 15),
          statut: PlageStatut.enAttente,
        ),
      ];
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: plages,
        prixNuit: 10000,
        year: 2026,
        month: 5,
      );
      // 5 jours en attente (10-14) → 31-5 = 26 jours potentiels
      expect(result, 26 * 10000);
    });

    test('prix nul → 0', () {
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: const [],
        prixNuit: 0,
        year: 2026,
        month: 5,
      );
      expect(result, 0);
    });

    test('prix négatif → 0', () {
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: const [],
        prixNuit: -100,
        year: 2026,
        month: 5,
      );
      expect(result, 0);
    });

    test('plage débordant le mois ne compte que les jours dans le mois', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 4, 25),
          fin: DateTime(2026, 5, 5),
          statut: PlageStatut.occupe,
        ),
      ];
      final result = ManqueAGagnerCalculator.computeForMonth(
        plages: plages,
        prixNuit: 10000,
        year: 2026,
        month: 5,
      );
      // Du 1er au 4 mai = 4 jours occupés dans le mois → 31-4 = 27
      expect(result, 27 * 10000);
    });
  });
}
