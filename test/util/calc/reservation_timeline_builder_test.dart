import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/model/reservation/reservation_plateforme.dart';
import 'package:asfar/model/reservation/reservation_timeline_event.dart';
import 'package:asfar/util/calc/reservation_timeline_builder.dart';

Reservation _r({
  DateTime? createdAt,
  ReservationStatus? statut,
  String? motif,
  Reservation? base,
}) {
  final r = base ?? ReservationPlateforme();
  r.createdAt = createdAt;
  r.statut = statut;
  r.motif = motif;
  return r;
}

void main() {
  group('ReservationTimelineBuilder - construction par statut', () {
    final created = DateTime(2026, 5, 3);

    test('enAttente → seulement created', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: created, statut: ReservationStatus.enAttente),
      );
      expect(events, hasLength(1));
      expect(events.first.type, ReservationTimelineEventType.created);
      expect(events.first.date, created);
    });

    test('confirmee → created + confirmed', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: created, statut: ReservationStatus.confirmee),
      );
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.confirmed,
      ]);
    });

    test('payee → created + confirmed + paid', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: created, statut: ReservationStatus.payee),
      );
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.confirmed,
        ReservationTimelineEventType.paid,
      ]);
    });

    test('finalisee → 4 étapes franchies', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: created, statut: ReservationStatus.finalisee),
      );
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.confirmed,
        ReservationTimelineEventType.paid,
        ReservationTimelineEventType.finalized,
      ]);
    });

    test('terminee → 5 étapes complètes', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: created, statut: ReservationStatus.terminee),
      );
      expect(events, hasLength(5));
      expect(events.last.type, ReservationTimelineEventType.terminated);
    });

    test('refusee → created + refused avec motif', () {
      final events = ReservationTimelineBuilder.build(
        _r(
          createdAt: created,
          statut: ReservationStatus.refusee,
          motif: 'Indisponible',
        ),
      );
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.refused,
      ]);
      expect(events.last.motif, 'Indisponible');
      expect(events.last.isNegative, isTrue);
    });

    test('annulee → created + cancelled avec motif', () {
      final events = ReservationTimelineBuilder.build(
        _r(
          createdAt: created,
          statut: ReservationStatus.annulee,
          motif: 'Changement de plan',
        ),
      );
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.cancelled,
      ]);
      expect(events.last.isNegative, isTrue);
    });
  });

  group('ReservationTimelineBuilder - cas limites', () {
    test('createdAt null → événement created absent', () {
      final events = ReservationTimelineBuilder.build(
        _r(statut: ReservationStatus.payee),
      );
      expect(
        events.map((e) => e.type),
        isNot(contains(ReservationTimelineEventType.created)),
      );
      expect(events, hasLength(2));
    });

    test('statut null → uniquement created si présent', () {
      final events = ReservationTimelineBuilder.build(
        _r(createdAt: DateTime(2026, 5, 3)),
      );
      expect(events, hasLength(1));
      expect(events.first.type, ReservationTimelineEventType.created);
    });

    test('reservation vide → liste vide', () {
      final events = ReservationTimelineBuilder.build(_r());
      expect(events, isEmpty);
    });
  });

  group('ReservationTimelineBuilder - règle manuelle', () {
    final created = DateTime(2026, 5, 3);

    test('manuelle confirmée → created + confirmed + paid (argent encaissé)', () {
      final events = ReservationTimelineBuilder.build(_r(
        createdAt: created,
        statut: ReservationStatus.confirmee,
        base: ReservationManuelle(),
      ));
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.confirmed,
        ReservationTimelineEventType.paid,
      ]);
    });

    test('manuelle terminée → 5 étapes (idem plateforme)', () {
      final events = ReservationTimelineBuilder.build(_r(
        createdAt: created,
        statut: ReservationStatus.terminee,
        base: ReservationManuelle(),
      ));
      expect(events, hasLength(5));
    });

    test('manuelle annulée → created + cancelled', () {
      final events = ReservationTimelineBuilder.build(_r(
        createdAt: created,
        statut: ReservationStatus.annulee,
        base: ReservationManuelle(),
      ));
      expect(events.map((e) => e.type), [
        ReservationTimelineEventType.created,
        ReservationTimelineEventType.cancelled,
      ]);
    });
  });

  group('ReservationTimelineBuilder.labelOf', () {
    test('chaque type a un libellé non vide', () {
      for (final t in ReservationTimelineEventType.values) {
        expect(ReservationTimelineBuilder.labelOf(t), isNotEmpty);
      }
    });
  });
}
