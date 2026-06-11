import 'dart:io';

import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/repository/appartement_repository.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/json_constructors_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../helpers/counting_http_client_adapter.dart';

/// Fixture minimale d'annonce (cache Hive ↔ API).
Map<String, dynamic> _appartJson({required int id, required String titre}) {
  return {
    'id': id,
    'titre': titre,
    'prix': 45000,
    'status': 'EN_LIGNE',
    'communeNom': 'Cocody',
    'villeNom': 'Abidjan',
  };
}

/// Tests du [AppartementRepository] (PRA-05) : cache Hive + appels API réels
/// (mockés au niveau HTTP via `http_mock_adapter`, car le repository est un
/// singleton qui instancie son [AppartementService] en interne).
///
/// IMPORTANT — SÉQUENCEMENT : repository et StorageService sont des
/// singletons partagés par tout le fichier (un seul process de test).
/// Les tests s'exécutent dans l'ordre de déclaration et le PREMIER test
/// doit être celui du versioning de cache : `_ensureCacheVersion` est
/// mémoïsé (`_versionChecked`) et ne s'exécute qu'au premier accès.
void main() {
  final feedPath = AppartementService.urlGetAppartements; // auth/appartement/apparts

  late DioAdapter dioAdapter;
  late AppartementRepository repository;
  final storage = StorageService.instance;

  setUpAll(() async {
    initializeJsonConstructors();
    // Hive en répertoire temporaire (PAS Hive.initFlutter : pas de canal
    // natif en test) + clé AES fixe pour éviter le Keychain.
    Hive.init(Directory.systemTemp.createTempSync().path);
    await storage.init(cipherOverride: HiveAesCipher(List.filled(32, 1)));
    repository = AppartementRepository();
    dioAdapter = DioAdapter(dio: DioRequest.instance.dioForTesting);
  });

  group('AppartementRepository — séquence singleton', () {
    test('version de cache différente → purge au premier accès', () async {
      // Empoisonner les deux caches + poser une version périmée.
      await storage.saveAppartements([_appartJson(id: 1, titre: 'Proprio périmé')]);
      await storage.saveAppartementsLocataire(
        [_appartJson(id: 2, titre: 'Feed périmé')],
      );
      await storage.setAppSetting<int>('cache_version_appartements', 999);

      dioAdapter.onGet(feedPath, (server) {
        server.reply(200, [_appartJson(id: 42, titre: 'Villa fraîche API')]);
      });

      final result = await repository.getAllAppartements();

      // Sans purge, le cache feed (frais) aurait été retourné tel quel (id 2).
      // Le résultat venant de l'API prouve que la purge a bien eu lieu.
      expect(result.map((a) => a.id), [42]);
      // Le cache proprio a aussi été purgé (clearCache vide les deux).
      expect(storage.getAppartements(), isEmpty);
      // La version stockée est réalignée sur la version courante.
      expect(
        storage.getAppSetting<int>('cache_version_appartements'),
        AppartementRepository.cacheVersion,
      );
    });

    test('cache vide → fetch API et mise en cache', () async {
      await repository.clearCache();
      dioAdapter.onGet(feedPath, (server) {
        server.reply(200, [_appartJson(id: 7, titre: 'Studio Plateau')]);
      });

      final result = await repository.getAllAppartements();

      expect(result, hasLength(1));
      expect(result.first.id, 7);
      // Mise en cache vérifiée directement dans Hive.
      final cached = storage.getAppartementsLocataire();
      expect(cached, hasLength(1));
      expect(cached.first['id'], 7);
      expect(storage.getAppartementsLocataireLastSync(), isNotNull);
    });

    test('cache frais → getAllAppartements ne déclenche AUCUNE requête HTTP',
        () async {
      // Cache feed posé à l'instant → frais (< 1 h).
      await storage.saveAppartementsLocataire(
        [_appartJson(id: 7, titre: 'Studio Plateau')],
      );
      // Adapter sentinelle : toute requête incrémente le compteur et lève.
      final counting = CountingHttpClientAdapter();
      DioRequest.instance.httpClientAdapterForTesting = counting;

      final result = await repository.getAllAppartements();

      expect(result.map((a) => a.id), [7]);
      expect(counting.callCount, 0,
          reason: 'cache frais : aucun appel réseau attendu');

      // Restaurer l'adapter mocké pour les tests suivants.
      DioRequest.instance.httpClientAdapterForTesting = dioAdapter;
    });

    test('fetchMoreAppartements(1) transmet page et size au serveur', () async {
      // La route mockée exige ?page=1&size=30 : elle ne matche que si la
      // pagination est réellement transmise.
      dioAdapter.onGet(
        feedPath,
        (server) => server.reply(200, [
          _appartJson(id: 8, titre: 'Appartement page 2'),
        ]),
        queryParameters: {'page': 1, 'size': 30},
      );

      final result = await repository.fetchMoreAppartements(1);

      expect(result, hasLength(1));
      expect(result.first.id, 8);
      // La pagination ne touche jamais le cache (seule la page 1 vit dans Hive).
      expect(
        storage.getAppartementsLocataire().map((j) => j['id']),
        isNot(contains(8)),
      );
    });
  });
}
