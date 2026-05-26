import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/util/calc/manual_reservation_validator.dart';

CalendarPlage _plage(DateTime debut, DateTime fin) {
  return CalendarPlage(
    debut: debut,
    fin: fin,
    statut: PlageStatut.occupe,
    type: PlageType.reservation,
  );
}

void main() {
  group('ManualReservationValidator.validateDates', () {
    test('debut null → invalide', () {
      final r = ManualReservationValidator.validateDates(null, null, []);
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('debut'), isTrue);
    });

    test('fin avant debut → invalide', () {
      final r = ManualReservationValidator.validateDates(
        DateTime(2026, 5, 15),
        DateTime(2026, 5, 14),
        [],
      );
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('fin'), isTrue);
    });

    test('fin = debut → invalide (durée nulle)', () {
      final r = ManualReservationValidator.validateDates(
        DateTime(2026, 5, 15),
        DateTime(2026, 5, 15),
        [],
      );
      expect(r.isValid, isFalse);
    });

    test('plage en conflit avec résa existante → invalide', () {
      final plages = [
        _plage(DateTime(2026, 5, 14), DateTime(2026, 5, 17)),
      ];
      final r = ManualReservationValidator.validateDates(
        DateTime(2026, 5, 15),
        DateTime(2026, 5, 16),
        plages,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('plage'), isTrue);
    });

    test('plage libre → valide', () {
      final plages = [
        _plage(DateTime(2026, 5, 14), DateTime(2026, 5, 15)),
      ];
      final r = ManualReservationValidator.validateDates(
        DateTime(2026, 5, 20),
        DateTime(2026, 5, 22),
        plages,
      );
      expect(r.isValid, isTrue);
    });

    test('dates passées autorisées (rétroactives)', () {
      final r = ManualReservationValidator.validateDates(
        DateTime(2020, 1, 1),
        DateTime(2020, 1, 5),
        [],
      );
      expect(r.isValid, isTrue);
    });
  });

  group('ManualReservationValidator.validateClient', () {
    test('nom vide → invalide', () {
      final r = ManualReservationValidator.validateClient('', '+22507000000');
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('nom'), isTrue);
    });

    test('nom whitespace → invalide', () {
      final r = ManualReservationValidator.validateClient('   ', '+22507000000');
      expect(r.isValid, isFalse);
    });

    test('téléphone vide → invalide', () {
      final r = ManualReservationValidator.validateClient('Test', '');
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('telephone'), isTrue);
    });

    test('nom + téléphone OK → valide', () {
      final r = ManualReservationValidator.validateClient(
        'Rachid B.',
        '+225 07 12 34 56',
      );
      expect(r.isValid, isTrue);
    });
  });

  group('ManualReservationValidator.validateSource', () {
    test('source null → invalide', () {
      final r = ManualReservationValidator.validateSource(null, null);
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('source'), isTrue);
    });

    test('source clientDirect → valide même sans démarcheurId', () {
      final r = ManualReservationValidator.validateSource(
        ReservationManuelleSource.clientDirect,
        null,
      );
      expect(r.isValid, isTrue);
    });

    test('source apporteur externe sans nom → invalide', () {
      final r = ManualReservationValidator.validateSource(
        ReservationManuelleSource.apporteurExterne,
        null,
      );
      expect(r.isValid, isFalse);
      expect(r.errors.containsKey('apporteurNom'), isTrue);
    });

    test('source apporteur externe avec nom → valide', () {
      final r = ManualReservationValidator.validateSource(
        ReservationManuelleSource.apporteurExterne,
        'Mamadou Cissé',
      );
      expect(r.isValid, isTrue);
    });
  });

  group('ManualReservationValidator.validatePaiement', () {
    test('moyen null → invalide', () {
      final r = ManualReservationValidator.validatePaiement(null);
      expect(r.isValid, isFalse);
    });

    test('moyen ESPECES → valide', () {
      final r = ManualReservationValidator.validatePaiement(MoyenPaiement.ESPECES);
      expect(r.isValid, isTrue);
    });
  });
}
