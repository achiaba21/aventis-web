import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/util/json_constructors_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Fixture réaliste : annonce complète telle que renvoyée par le backend
/// (champs aplatis `communeNom`/`villeNom` depuis BACKEND-FLAT-APPART).
Map<String, dynamic> _appartJson({
  required int id,
  required String titre,
  num prix = 45000,
  String status = 'EN_LIGNE',
}) {
  return {
    'id': id,
    'titre': titre,
    'description': 'Logement meublé, climatisé, proche commodités',
    'prix': prix,
    'numero': 'A-$id',
    'imgUrl': 'https://cdn.asfar.ci/photos/appart-$id.jpg',
    'likes': 12,
    'visible': true,
    'status': status,
    'communeNom': 'Cocody',
    'villeNom': 'Abidjan',
    'nbLits': 3,
    'nbChambres': 2,
    'nbDouches': 1,
    'note': 4.5,
    'createdAt': '2026-05-01T10:00:00.000',
  };
}

/// Tests du service API [AppartementService] (PRA-05).
///
/// Le backend est simulé via `http_mock_adapter`. L'endpoint liste
/// (`auth/appartement/apparts`) renvoie le tableau JSON brut, mappé par
/// `getMapped<Appartement>` via le registre de constructeurs JSON.
void main() {
  late DioAdapter dioAdapter;
  late AppartementService service;

  setUpAll(() {
    initializeJsonConstructors();
    dioAdapter = DioAdapter(dio: DioRequest.instance.dioForTesting);
    service = AppartementService();
  });

  group('AppartementService.getAppartements', () {
    test('liste mappée depuis la réponse backend', () async {
      dioAdapter.onGet(AppartementService.urlGetAppartements, (server) {
        server.reply(200, [
          _appartJson(id: 1, titre: 'Villa Cocody Riviera'),
          _appartJson(id: 2, titre: 'Studio Plateau', prix: 20000, status: 'EN_COURS'),
        ]);
      });

      final result = await service.getAppartements();

      expect(result, hasLength(2));
      expect(result.first.id, 1);
      expect(result.first.titre, 'Villa Cocody Riviera');
      expect(result.first.status, AppartementStatus.EN_LIGNE);
      expect(result.first.communeNom, 'Cocody');
      expect(result.first.localiteLabel, 'Cocody, Abidjan');
      expect(result.last.prix, 20000.0);
      expect(result.last.status, AppartementStatus.EN_COURS);
    });

    test('getAppartements(page: 1, size: 30) envoie les query params', () async {
      // La route mockée exige ?page=1&size=30 : elle ne matche que si le
      // service transmet effectivement la pagination au serveur.
      dioAdapter.onGet(
        AppartementService.urlGetAppartements,
        (server) => server.reply(200, [
          _appartJson(id: 31, titre: 'Appartement page suivante'),
        ]),
        queryParameters: {'page': 1, 'size': 30},
      );

      final result = await service.getAppartements(page: 1, size: 30);

      expect(result, hasLength(1));
      expect(result.first.id, 31);
    });

    test('item corrompu dans la liste → ignoré, les autres sont mappés', () async {
      // Résilience ResponseMapper : un item dont le mapping échoue (id non
      // entier ici) ou qui n'est pas un Map est ignoré + loggué, sans faire
      // échouer toute la liste.
      dioAdapter.onGet(AppartementService.urlGetAppartements, (server) {
        server.reply(200, [
          _appartJson(id: 1, titre: 'Villa Cocody Riviera'),
          {'id': 'pas-un-entier', 'titre': 'Annonce corrompue'}, // → ignoré
          'élément texte', // pas un Map → ignoré
          _appartJson(id: 3, titre: 'Duplex Marcory'),
        ]);
      });

      final result = await service.getAppartements();

      expect(result, hasLength(2));
      expect(result.map((a) => a.id), [1, 3]);
    });
  });
}
