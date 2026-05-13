import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/util/calc/calendar_availability.dart';

CalendarPlage _plage(
  DateTime debut,
  DateTime fin, {
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
  group('CalendarAvailability.isDayAvailable', () {
    test('jour avant toutes les plages → libre', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 5), plages),
        isTrue,
      );
    });

    test('jour après toutes les plages → libre', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 20), plages),
        isTrue,
      );
    });

    test('jour dans plage OCCUPE → bloqué', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 12), plages),
        isFalse,
      );
    });

    test('jour dans plage EN_ATTENTE → bloqué', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15),
            statut: PlageStatut.enAttente),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 12), plages),
        isFalse,
      );
    });

    test('borne fin de plage exclue → libre (jour check-out libérable)', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 15), plages),
        isTrue,
        reason: 'containsDay exclut la borne fin',
      );
    });

    test('plage DISPONIBLE n\'invalide pas → libre', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15),
            statut: PlageStatut.disponible),
      ];
      expect(
        CalendarAvailability.isDayAvailable(DateTime(2026, 6, 12), plages),
        isTrue,
      );
    });

    test('selfExclude annule l\'exclusion sur sa propre plage', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(
          DateTime(2026, 6, 12),
          plages,
          selfStart: DateTime(2026, 6, 10),
          selfEnd: DateTime(2026, 6, 15),
        ),
        isTrue,
      );
    });

    test('selfExclude ne masque pas une autre plage', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
        _plage(DateTime(2026, 6, 20), DateTime(2026, 6, 25)),
      ];
      expect(
        CalendarAvailability.isDayAvailable(
          DateTime(2026, 6, 22),
          plages,
          selfStart: DateTime(2026, 6, 10),
          selfEnd: DateTime(2026, 6, 15),
        ),
        isFalse,
      );
    });
  });

  group('CalendarAvailability.isRangeAvailable', () {
    test('plage entièrement avant → libre', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isRangeAvailable(
          DateTime(2026, 6, 1),
          DateTime(2026, 6, 5),
          plages,
        ),
        isTrue,
      );
    });

    test('plage qui intersecte un OCCUPE → bloquée', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isRangeAvailable(
          DateTime(2026, 6, 12),
          DateTime(2026, 6, 18),
          plages,
        ),
        isFalse,
      );
    });

    test('check-in le jour du check-out d\'une autre résa → libre', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isRangeAvailable(
          DateTime(2026, 6, 15),
          DateTime(2026, 6, 20),
          plages,
        ),
        isTrue,
      );
    });

    test('selfExclude autorise une plage qui couvre sa propre résa', () {
      final plages = [
        _plage(DateTime(2026, 6, 10), DateTime(2026, 6, 15)),
      ];
      expect(
        CalendarAvailability.isRangeAvailable(
          DateTime(2026, 6, 11),
          DateTime(2026, 6, 14),
          plages,
          selfStart: DateTime(2026, 6, 10),
          selfEnd: DateTime(2026, 6, 15),
        ),
        isTrue,
      );
    });
  });
}
