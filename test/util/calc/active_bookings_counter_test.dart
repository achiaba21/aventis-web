import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/util/calc/active_bookings_counter.dart';

Reservation _res({
  DateTime? debut,
  DateTime? fin,
  ReservationStatus? statut,
}) {
  final r = ReservationManuelle();
  r.debut = debut;
  r.fin = fin;
  r.statut = statut;
  return r;
}

void main() {
  final now = DateTime(2026, 5, 15);

  group('ActiveBookingsCounter.activeToday', () {
    test('aucune réservation → 0', () {
      expect(ActiveBookingsCounter.activeToday([], now: now), 0);
    });

    test('réservation confirmée qui couvre aujourd\'hui → 1', () {
      final r = _res(
        debut: DateTime(2026, 5, 14),
        fin: DateTime(2026, 5, 17),
        statut: ReservationStatus.confirmee,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 1);
    });

    test('réservation finalisée qui couvre aujourd\'hui → 1', () {
      final r = _res(
        debut: DateTime(2026, 5, 14),
        fin: DateTime(2026, 5, 17),
        statut: ReservationStatus.finalisee,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 1);
    });

    test('réservation en attente → 0 (pas active)', () {
      final r = _res(
        debut: DateTime(2026, 5, 14),
        fin: DateTime(2026, 5, 17),
        statut: ReservationStatus.enAttente,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 0);
    });

    test('réservation annulée → 0', () {
      final r = _res(
        debut: DateTime(2026, 5, 14),
        fin: DateTime(2026, 5, 17),
        statut: ReservationStatus.annulee,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 0);
    });

    test('réservation finie hier → 0 (fin exclue)', () {
      final r = _res(
        debut: DateTime(2026, 5, 10),
        fin: DateTime(2026, 5, 15), // check-out aujourd'hui
        statut: ReservationStatus.confirmee,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 0);
    });

    test('réservation commencée aujourd\'hui → 1 (debut inclus)', () {
      final r = _res(
        debut: DateTime(2026, 5, 15),
        fin: DateTime(2026, 5, 17),
        statut: ReservationStatus.confirmee,
      );
      expect(ActiveBookingsCounter.activeToday([r], now: now), 1);
    });

    test('multi-réservations actives → compte correct', () {
      final list = [
        _res(
          debut: DateTime(2026, 5, 14),
          fin: DateTime(2026, 5, 16),
          statut: ReservationStatus.confirmee,
        ),
        _res(
          debut: DateTime(2026, 5, 15),
          fin: DateTime(2026, 5, 20),
          statut: ReservationStatus.payee,
        ),
        _res(
          debut: DateTime(2026, 5, 16),
          fin: DateTime(2026, 5, 18),
          statut: ReservationStatus.confirmee,
        ),
        _res(
          debut: DateTime(2026, 5, 12),
          fin: DateTime(2026, 5, 13),
          statut: ReservationStatus.confirmee,
        ),
      ];
      // 1 (14-16) + 2 (15-20) = 2 actives ; 3 (16-18) débute demain ; 4 finie.
      expect(ActiveBookingsCounter.activeToday(list, now: now), 2);
    });

    test('dates null → ignoré', () {
      final r = _res(statut: ReservationStatus.confirmee);
      expect(ActiveBookingsCounter.activeToday([r], now: now), 0);
    });
  });
}
