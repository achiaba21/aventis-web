import 'dart:io';

import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/repository/reservation_repository.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/json_constructors_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../helpers/counting_http_client_adapter.dart';

/// Fixture minimale de réservation plateforme (cache Hive ↔ API).
Map<String, dynamic> _reservationJson({
  required int id,
  required String reference,
}) {
  return {
    'id': id,
    'reference': reference,
    'debut': '2026-06-10T00:00:00.000',
    'fin': '2026-06-14T00:00:00.000',
    'prix': 180000,
    'statut': 'CONFIRMER',
    'type': 'PLATEFORME',
  };
}

/// Tests du [ReservationRepository] (PRA-05) : cache Hive + appels API
/// mockés au niveau HTTP (le repository singleton instancie son
/// [ReservationService] en interne — non injectable).
///
/// IMPORTANT — SÉQUENCEMENT : repository et StorageService sont des
/// singletons partagés par tout le fichier ; les tests s'exécutent dans
/// l'ordre de déclaration (un seul `main()`, un seul `setUpAll`).
void main() {
  late ReservationRepository repository;
  final storage = StorageService.instance;

  setUpAll(() async {
    initializeJsonConstructors();
    // Hive en répertoire temporaire (PAS Hive.initFlutter : pas de canal
    // natif en test) + clé AES fixe pour éviter le Keychain.
    Hive.init(Directory.systemTemp.createTempSync().path);
    await storage.init(cipherOverride: HiveAesCipher(List.filled(32, 1)));
    repository = ReservationRepository();
  });

  group('ReservationRepository.getUserReservations — séquence singleton', () {
    test('cache frais (< 15 min) → aucun appel HTTP', () async {
      // Cache posé à l'instant → frais.
      await storage.saveReservations(
        [_reservationJson(id: 11, reference: 'ASF-7K2N9')],
      );
      // Adapter sentinelle : toute requête incrémente le compteur et lève.
      final counting = CountingHttpClientAdapter();
      DioRequest.instance.httpClientAdapterForTesting = counting;

      final result = await repository.getUserReservations();

      expect(result.isFromCache, isTrue);
      expect(result.reservations, hasLength(1));
      expect(result.reservations.first.reference, 'ASF-7K2N9');
      expect(counting.callCount, 0,
          reason: 'cache frais : aucun appel réseau attendu');
    });

    test('cache vide + API en échec → liste vide depuis le cache, sans exception',
        () async {
      await repository.clearUserCache();
      // API en échec : 500 systématique.
      final dioAdapter = DioAdapter(dio: DioRequest.instance.dioForTesting);
      dioAdapter.onGet(ReservationService.urlGetUserReservations, (server) {
        server.reply(500, {'message': 'Erreur serveur interne'});
      });

      final result = await repository.getUserReservations();

      // Mode offline avec cache vide : politique « pas de crash UI ».
      expect(result.reservations, isEmpty);
      expect(result.isFromCache, isTrue);
    });

    test('forceRefresh avec API en échec → fallback sur le cache', () async {
      // Cache présent + API toujours en 500 (route enregistrée au test
      // précédent, l'adapter mocké est resté branché).
      await storage.saveReservations(
        [_reservationJson(id: 12, reference: 'ASF-3F8XA')],
      );

      final result = await repository.getUserReservations(forceRefresh: true);

      expect(result.isFromCache, isTrue,
          reason: 'API en échec : le repository doit retomber sur le cache');
      expect(result.reservations, hasLength(1));
      expect(result.reservations.first.reference, 'ASF-3F8XA');
    });
  });
}
