import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_plateforme.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/calc/proprio_reservations_filter.dart';
import 'package:asfar/util/calc/reservation_segment.dart';
import 'package:flutter_test/flutter_test.dart';

/// `now` fixe pour des tests déterministes.
final _now = DateTime(2026, 6, 30);

Reservation _r({
  required ReservationStatus statut,
  int? appartId,
  DateTime? debut,
  DateTime? fin,
  DateTime? createdAt,
}) {
  return ReservationPlateforme()
    ..statut = statut
    ..appart = appartId == null ? null : Appartement(id: appartId)
    ..debut = debut
    ..fin = fin
    ..createdAt = createdAt;
}

void main() {
  group('ReservationSegment.segmentOf', () {
    test('en attente → à traiter (même si date passée)', () {
      final r = _r(
        statut: ReservationStatus.enAttente,
        fin: DateTime(2026, 1, 1),
      );
      expect(ReservationSegment.segmentOf(r, now: _now),
          ReservationSegment.aTraiter);
    });

    test('confirmée avec fin future → à venir', () {
      final r = _r(
        statut: ReservationStatus.confirmee,
        fin: DateTime(2026, 7, 15),
      );
      expect(ReservationSegment.segmentOf(r, now: _now),
          ReservationSegment.aVenir);
    });

    test('payée se terminant aujourd\'hui → à venir (jour inclus)', () {
      final r = _r(
        statut: ReservationStatus.payee,
        fin: DateTime(2026, 6, 30, 23),
      );
      expect(ReservationSegment.segmentOf(r, now: _now),
          ReservationSegment.aVenir);
    });

    test('confirmée passée non clôturée → historique', () {
      final r = _r(
        statut: ReservationStatus.confirmee,
        fin: DateTime(2026, 6, 20),
      );
      expect(ReservationSegment.segmentOf(r, now: _now),
          ReservationSegment.historique);
    });

    test('finalisée et annulée → historique', () {
      expect(
        ReservationSegment.segmentOf(
            _r(statut: ReservationStatus.finalisee), now: _now),
        ReservationSegment.historique,
      );
      expect(
        ReservationSegment.segmentOf(
            _r(statut: ReservationStatus.annulee), now: _now),
        ReservationSegment.historique,
      );
    });

    test('fin nulle sur résa active → à venir (pas masquée)', () {
      final r = _r(statut: ReservationStatus.confirmee, fin: null);
      expect(ReservationSegment.segmentOf(r, now: _now),
          ReservationSegment.aVenir);
    });
  });

  group('ProprioReservationsFilter.counts', () {
    final all = [
      _r(statut: ReservationStatus.enAttente, appartId: 1),
      _r(statut: ReservationStatus.enAttente, appartId: 2),
      _r(
        statut: ReservationStatus.confirmee,
        appartId: 1,
        fin: DateTime(2026, 7, 10),
      ),
      _r(statut: ReservationStatus.annulee, appartId: 2),
      _r(statut: ReservationStatus.finalisee, appartId: 1),
    ];

    test('compte chaque segment, tous biens', () {
      final c = ProprioReservationsFilter.counts(all: all, now: _now);
      expect(c[ReservationSegment.aTraiter], 2);
      expect(c[ReservationSegment.aVenir], 1);
      expect(c[ReservationSegment.historique], 2);
    });

    test('respecte le filtre bien', () {
      final c = ProprioReservationsFilter.counts(
        all: all,
        now: _now,
        appartementId: 1,
      );
      expect(c[ReservationSegment.aTraiter], 1);
      expect(c[ReservationSegment.aVenir], 1);
      expect(c[ReservationSegment.historique], 1);
    });
  });

  group('ProprioReservationsFilter.apply', () {
    test('filtre par segment + bien', () {
      final all = [
        _r(statut: ReservationStatus.enAttente, appartId: 1),
        _r(statut: ReservationStatus.enAttente, appartId: 2),
      ];
      final res = ProprioReservationsFilter.apply(
        all: all,
        segment: ReservationSegment.aTraiter,
        now: _now,
        appartementId: 1,
      );
      expect(res.length, 1);
      expect(res.single.appart?.id, 1);
    });

    test('à traiter trié par createdAt croissant (plus ancien d\'abord)', () {
      final recent = _r(
        statut: ReservationStatus.enAttente,
        createdAt: DateTime(2026, 6, 29),
      );
      final ancien = _r(
        statut: ReservationStatus.enAttente,
        createdAt: DateTime(2026, 6, 1),
      );
      final res = ProprioReservationsFilter.apply(
        all: [recent, ancien],
        segment: ReservationSegment.aTraiter,
        now: _now,
      );
      expect(res.first, same(ancien));
      expect(res.last, same(recent));
    });

    test('à venir trié par debut croissant (arrivée la plus proche d\'abord)',
        () {
      final loin = _r(
        statut: ReservationStatus.confirmee,
        debut: DateTime(2026, 8, 1),
        fin: DateTime(2026, 8, 5),
      );
      final proche = _r(
        statut: ReservationStatus.confirmee,
        debut: DateTime(2026, 7, 2),
        fin: DateTime(2026, 7, 6),
      );
      final res = ProprioReservationsFilter.apply(
        all: [loin, proche],
        segment: ReservationSegment.aVenir,
        now: _now,
      );
      expect(res.first, same(proche));
      expect(res.last, same(loin));
    });

    test('historique trié par fin décroissant (plus récent d\'abord)', () {
      final vieux = _r(
        statut: ReservationStatus.finalisee,
        fin: DateTime(2026, 1, 10),
      );
      final recent = _r(
        statut: ReservationStatus.finalisee,
        fin: DateTime(2026, 5, 20),
      );
      final res = ProprioReservationsFilter.apply(
        all: [vieux, recent],
        segment: ReservationSegment.historique,
        now: _now,
      );
      expect(res.first, same(recent));
      expect(res.last, same(vieux));
    });
  });

  group('ProprioReservationsFilter.distinctAppartements', () {
    test('déduplique par id et trie par titre', () {
      final all = [
        _r(statut: ReservationStatus.enAttente)
          ..appart = Appartement(id: 2, titre: 'Studio'),
        _r(statut: ReservationStatus.enAttente)
          ..appart = Appartement(id: 1, titre: 'Appart'),
        _r(statut: ReservationStatus.enAttente)
          ..appart = Appartement(id: 1, titre: 'Appart'),
        _r(statut: ReservationStatus.enAttente)..appart = null,
      ];
      final biens = ProprioReservationsFilter.distinctAppartements(all);
      expect(biens.map((a) => a.id).toList(), [1, 2]);
    });
  });
}
