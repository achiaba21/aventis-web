import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/util/calc/tip_suggestion_engine.dart';

CalendarPlage _plage({
  required DateTime debut,
  required DateTime fin,
  PlageStatut statut = PlageStatut.occupe,
}) {
  return CalendarPlage(
    debut: debut,
    fin: fin,
    statut: statut,
    type: PlageType.reservation,
  );
}

void main() {
  // Mercredi 13 mai 2026 → semaine lundi 11 au dimanche 17 mai
  final now = DateTime(2026, 5, 13);

  group('TipSuggestionEngine.computeForCurrentWeek', () {
    test('semaine totalement libre → suggestion plafonnée à 4 jours', () {
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: const [],
        prixNuit: 50000,
        now: now,
      );
      expect(result, isNotNull);
      expect(result!.joursOuvrables, 4);
      // 4 × 50000 × 0.70 = 140 000
      expect(result.gainPotentielFcfa, 140000);
    });

    test('semaine totalement occupée → null', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 11),
          fin: DateTime(2026, 5, 18),
          statut: PlageStatut.occupe,
        ),
      ];
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: plages,
        prixNuit: 50000,
        now: now,
      );
      expect(result, isNull);
    });

    test('3 jours libres → null (sous le seuil 4)', () {
      // 4 jours occupés, 3 jours libres
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 11),
          fin: DateTime(2026, 5, 15), // 11, 12, 13, 14 occupés
        ),
      ];
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: plages,
        prixNuit: 50000,
        now: now,
      );
      expect(result, isNull);
    });

    test('exactement 4 jours libres → suggestion (4 jours)', () {
      // 3 jours occupés (11-13), 4 libres (14, 15, 16, 17)
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 11),
          fin: DateTime(2026, 5, 14),
        ),
      ];
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: plages,
        prixNuit: 50000,
        now: now,
      );
      expect(result, isNotNull);
      expect(result!.joursOuvrables, 4);
    });

    test('plages disponibles (blocages) comptent comme libres', () {
      // Toute la semaine est en blocage proprio → équivaut à libre
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 11),
          fin: DateTime(2026, 5, 18),
          statut: PlageStatut.disponible, // blocage
        ),
      ];
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: plages,
        prixNuit: 50000,
        now: now,
      );
      expect(result, isNotNull);
      expect(result!.joursOuvrables, 4);
    });

    test('taux historique fourni → utilisé au lieu du fallback 70%', () {
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: const [],
        prixNuit: 50000,
        tauxOccupationHistorique: 0.90,
        now: now,
      );
      // 4 × 50000 × 0.90 = 180 000
      expect(result!.gainPotentielFcfa, 180000);
    });

    test('prix nul → null', () {
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: const [],
        prixNuit: 0,
        now: now,
      );
      expect(result, isNull);
    });

    test('seulement dimanche occupé → 6 libres → suggestion plafonnée à 4', () {
      final plages = [
        _plage(
          debut: DateTime(2026, 5, 17),
          fin: DateTime(2026, 5, 18),
        ),
      ];
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: plages,
        prixNuit: 50000,
        now: now,
      );
      expect(result!.joursOuvrables, 4); // plafonné
    });

    test('semaine en plein milieu de la nuit → utilise dateOnly', () {
      // Mercredi 13 mai à 23h59
      final lateNight = DateTime(2026, 5, 13, 23, 59);
      final result = TipSuggestionEngine.computeForCurrentWeek(
        plages: const [],
        prixNuit: 50000,
        now: lateNight,
      );
      expect(result, isNotNull); // toujours dans la même semaine
    });
  });
}
