import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/json_constructors_registry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Tests de la couche HTTP centrale [DioRequest] (PRA-05).
///
/// Le backend est simulé via `http_mock_adapter`, branché sur le client Dio
/// interne grâce au crochet de test `dioForTesting`.
///
/// HORS PÉRIMÈTRE (volontairement non testé ici) :
/// - Le retry réseau automatique (`_retryWhenOnline`) : il dépend de
///   `ConnectivityService` (socket temps réel) — non simulable proprement
///   en test unitaire sans infrastructure dédiée.
/// - La gestion du 401 (déconnexion + navigation vers le SplashScreen) :
///   elle dépend de `AuthManager`, `UserBloc` et du `navigatorKey` — flux
///   d'intégration, hors périmètre d'un test de la couche données.
void main() {
  const path = 'auth/appartement/apparts';

  late DioAdapter dioAdapter;

  setUpAll(() {
    // Enregistre Appartement.fromJson dans le registre pour que getMapped<T>
    // sache désérialiser (même initialisation qu'au démarrage de l'app).
    initializeJsonConstructors();
    dioAdapter = DioAdapter(dio: DioRequest.instance.dioForTesting);
  });

  group('DioRequest.getMapped — mapping automatique', () {
    test('une liste d\'objets JSON est mappée en List<Appartement>', () async {
      // NOTE : l'endpoint liste retourne le tableau JSON brut `[...]`.
      // Le wrapper Spring `{body: [...], message}` n'est PAS déballé par
      // `getMapped` (comportement actuel de `ResponseMapper.mapResponseAuto`) ;
      // l'extraction du wrapper est couverte par les tests de
      // `ResponseMapper.tryExtractBodyList` et ceux de ReservationService.
      dioAdapter.onGet(path, (server) {
        server.reply(200, [
          {
            'id': 1,
            'titre': 'Villa Cocody Riviera',
            'prix': 45000,
            'status': 'EN_LIGNE',
            'communeNom': 'Cocody',
            'villeNom': 'Abidjan',
          },
          {
            'id': 2,
            'titre': 'Studio Plateau',
            'prix': 20000,
            'status': 'EN_COURS',
          },
        ]);
      });

      final result = await DioRequest.instance.getMapped<Appartement>(path);

      expect(result, hasLength(2));
      expect(result.first.id, 1);
      expect(result.first.titre, 'Villa Cocody Riviera');
      expect(result.first.prix, 45000.0);
      expect(result.last.id, 2);
    });

    test('réponse 500 → DioException propagée avec message propre', () async {
      dioAdapter.onGet(path, (server) {
        server.reply(500, {'message': 'Erreur serveur interne'});
      });

      // L'intercepteur d'erreur extrait le message backend (ErrorHandler)
      // et le replace dans une DioException « propre ».
      await expectLater(
        DioRequest.instance.getMapped<Appartement>(path),
        throwsA(
          isA<DioException>()
              .having((e) => e.message, 'message', 'Erreur serveur interne'),
        ),
      );
    });

    test('les queryParameters sont transmis au serveur', () async {
      // La route mockée n'accepte QUE ?page=1&size=30 : si les paramètres
      // n'étaient pas transmis, aucune route ne matcherait et l'appel
      // échouerait — le succès prouve la transmission.
      dioAdapter.onGet(
        path,
        (server) => server.reply(200, [
          {'id': 31, 'titre': 'Appartement page 2', 'prix': 30000},
        ]),
        queryParameters: {'page': 1, 'size': 30},
      );

      final result = await DioRequest.instance.getMapped<Appartement>(
        path,
        queryParameters: {'page': 1, 'size': 30},
      );

      expect(result, hasLength(1));
      expect(result.first.id, 31);
    });
  });
}
