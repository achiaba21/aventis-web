import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/model/reservation/reservation_plateforme.dart';

Reservation _r(ReservationStatus statut, {Reservation? base}) {
  final r = base ?? ReservationPlateforme();
  r.statut = statut;
  return r;
}

void main() {
  group('ReservationCounted.isEncaissed - plateforme', () {
    test('enAttente → false', () {
      expect(_r(ReservationStatus.enAttente).isEncaissed, isFalse);
    });

    test('confirmee plateforme → false (pas encore payée)', () {
      expect(_r(ReservationStatus.confirmee).isEncaissed, isFalse);
    });

    test('payee → true', () {
      expect(_r(ReservationStatus.payee).isEncaissed, isTrue);
    });

    test('finalisee → true', () {
      expect(_r(ReservationStatus.finalisee).isEncaissed, isTrue);
    });

    test('terminee → true', () {
      expect(_r(ReservationStatus.terminee).isEncaissed, isTrue);
    });

    test('refusee/annulee → false', () {
      expect(_r(ReservationStatus.refusee).isEncaissed, isFalse);
      expect(_r(ReservationStatus.annulee).isEncaissed, isFalse);
    });
  });

  group('ReservationCounted.isEncaissed - manuelle (règle métier)', () {
    test('confirmee manuelle → true (argent encaissé hors plateforme)', () {
      final r = _r(ReservationStatus.confirmee, base: ReservationManuelle());
      expect(r.isEncaissed, isTrue);
    });

    test('enAttente manuelle → false', () {
      final r = _r(ReservationStatus.enAttente, base: ReservationManuelle());
      expect(r.isEncaissed, isFalse);
    });

    test('terminee manuelle → true', () {
      final r = _r(ReservationStatus.terminee, base: ReservationManuelle());
      expect(r.isEncaissed, isTrue);
    });

    test('annulee manuelle → false (remboursement effectué hors-app)', () {
      final r = _r(ReservationStatus.annulee, base: ReservationManuelle());
      expect(r.isEncaissed, isFalse);
    });
  });

  group('ReservationCounted.isPipeline', () {
    test('confirmee plateforme → true', () {
      expect(_r(ReservationStatus.confirmee).isPipeline, isTrue);
    });

    test('confirmee manuelle → false (déjà encaissée, hors pipeline)', () {
      final r = _r(ReservationStatus.confirmee, base: ReservationManuelle());
      expect(r.isPipeline, isFalse);
    });

    test('payee → false (encaissée, pas pipeline)', () {
      expect(_r(ReservationStatus.payee).isPipeline, isFalse);
    });
  });
}
