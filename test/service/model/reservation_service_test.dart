import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Fixture réaliste : réservation plateforme telle que renvoyée par le backend.
Map<String, dynamic> _reservationJson({
  required int id,
  required String reference,
  String statut = 'CONFIRMER',
}) {
  return {
    'id': id,
    'reference': reference,
    'debut': '2026-06-10T00:00:00.000',
    'fin': '2026-06-14T00:00:00.000',
    'prix': 180000,
    'frais': 5000,
    'statut': statut,
    'type': 'PLATEFORME',
    'moyenPaiement': 'WAVE',
    'createdAt': '2026-06-01T09:30:00.000',
    'appart': {
      'id': 5,
      'titre': 'Studio Plateau',
      'prix': 45000,
      'communeNom': 'Plateau',
      'villeNom': 'Abidjan',
    },
  };
}

/// Tests du service API [ReservationService] (PRA-05).
///
/// Le backend est simulé via `http_mock_adapter`. Les réponses suivent le
/// wrapper Spring Boot `{body: ..., message: ...}` extrait par
/// `ResponseMapper.tryExtractBody*`.
void main() {
  late DioAdapter dioAdapter;
  late ReservationService service;

  setUpAll(() {
    dioAdapter = DioAdapter(dio: DioRequest.instance.dioForTesting);
    service = ReservationService();
  });

  group('ReservationService.getUserReservations', () {
    test('mappe {body: [...]} en List<Reservation>', () async {
      dioAdapter.onGet(ReservationService.urlGetUserReservations, (server) {
        server.reply(200, {
          'body': [
            _reservationJson(id: 11, reference: 'ASF-7K2N9'),
            _reservationJson(id: 12, reference: 'ASF-3F8XA', statut: 'EN_ATTENTE'),
          ],
          'message': 'success',
        });
      });

      final result = await service.getUserReservations();

      expect(result, hasLength(2));
      expect(result.first.reference, 'ASF-7K2N9');
      expect(result.first.statut, ReservationStatus.confirmee);
      expect(result.first.prix, 180000.0);
      expect(result.first.appart?.id, 5);
      expect(result.last.statut, ReservationStatus.enAttente);
    });

    test('body malformé (pas une liste) → retourne [] sans exception', () async {
      // Politique conservée : si le backend renvoie autre chose qu'une liste
      // dans `body`, le service retourne une liste vide (pas de crash UI).
      dioAdapter.onGet(ReservationService.urlGetUserReservations, (server) {
        server.reply(200, {
          'body': {'inattendu': true},
          'message': 'success',
        });
      });

      final result = await service.getUserReservations();

      expect(result, isEmpty);
    });
  });

  group('ReservationService.createReservation', () {
    ReservationReq buildReq() => ReservationReq(
          appartement: Appartement(id: 5),
          plage: DateTimeRange(
            start: DateTime(2026, 6, 10),
            end: DateTime(2026, 6, 14),
          ),
          moyenPaiement: MoyenPaiement.WAVE,
        );

    test('{body: {success: true, reservation: {...}}} → Reservation', () async {
      dioAdapter.onPost(
        ReservationService.urlCreateReservation,
        (server) => server.reply(200, {
          'body': {
            'success': true,
            'message': 'Réservation créée',
            'reservation': _reservationJson(id: 21, reference: 'ASF-9Z4QW', statut: 'EN_ATTENTE'),
            'reference': 'ASF-9Z4QW',
          },
          'message': 'success',
        }),
        data: Matchers.any,
      );

      final reservation = await service.createReservation(buildReq());

      expect(reservation.id, 21);
      expect(reservation.reference, 'ASF-9Z4QW');
      expect(reservation.statut, ReservationStatus.enAttente);
    });

    test('{body: {success: false, message: X}} → exception avec message X', () async {
      dioAdapter.onPost(
        ReservationService.urlCreateReservation,
        (server) => server.reply(200, {
          'body': {
            'success': false,
            'message': 'Dates indisponibles pour ce logement',
          },
          'message': 'success',
        }),
        data: Matchers.any,
      );

      await expectLater(
        service.createReservation(buildReq()),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Dates indisponibles pour ce logement'),
          ),
        ),
      );
    });
  });
}
