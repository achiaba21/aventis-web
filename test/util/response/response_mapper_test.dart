import 'package:asfar/util/response/response_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Construit une réponse Dio 200 portant [data].
Response<dynamic> _ok(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
      data: data,
    );

/// fromJson factice : lève si l'item ne contient pas `v` (int).
int _intFromJson(Map<String, dynamic> json) {
  final v = json['v'];
  if (v is! int) throw const FormatException('champ v invalide');
  return v;
}

void main() {
  group('ResponseMapper.mapResponseAuto — résilience liste', () {
    test('un item fautif est ignoré, les autres sont mappés', () {
      final response = _ok([
        {'v': 1},
        {'v': 'pas un int'}, // throw → ignoré
        {'v': 3},
      ]);

      final result = ResponseMapper.mapResponseAuto<int>(
        response: response,
        fromJsonConstructor: _intFromJson,
      );

      expect(result, [1, 3]);
    });

    test('un item de type non-Map est ignoré', () {
      final response = _ok([
        {'v': 1},
        'élément texte', // pas un Map → ignoré
        {'v': 2},
      ]);

      final result = ResponseMapper.mapResponseAuto<int>(
        response: response,
        fromJsonConstructor: _intFromJson,
      );

      expect(result, [1, 2]);
    });

    test('liste entièrement valide → tout est mappé', () {
      final response = _ok([
        {'v': 10},
        {'v': 20},
      ]);

      final result = ResponseMapper.mapResponseAuto<int>(
        response: response,
        fromJsonConstructor: _intFromJson,
      );

      expect(result, [10, 20]);
    });

    test('objet unique → liste à un élément', () {
      final result = ResponseMapper.mapResponseAuto<int>(
        response: _ok({'v': 42}),
        fromJsonConstructor: _intFromJson,
      );

      expect(result, [42]);
    });
  });

  group('ResponseMapper.tryExtractBody (PRA-02)', () {
    test('extrait le body du wrapper {body, message}', () {
      final result = ResponseMapper.tryExtractBody({
        'body': {'id': 1, 'nom': 'Villa'},
        'message': 'OK',
      });
      expect(result, {'id': 1, 'nom': 'Villa'});
    });

    test('retourne la map telle quelle si déjà à plat (sans wrapper)', () {
      final result = ResponseMapper.tryExtractBody({'id': 7, 'nom': 'Studio'});
      expect(result, {'id': 7, 'nom': 'Studio'});
    });

    test('retourne la map à plat si body est null', () {
      final result = ResponseMapper.tryExtractBody({'body': null, 'id': 3});
      expect(result, {'body': null, 'id': 3});
    });

    test('retourne null si data n\'est pas un Map', () {
      expect(ResponseMapper.tryExtractBody('texte'), isNull);
      expect(ResponseMapper.tryExtractBody(null), isNull);
      expect(ResponseMapper.tryExtractBody([1, 2]), isNull);
    });
  });

  group('ResponseMapper.tryExtractBodyList (PRA-02)', () {
    test('extrait la liste du wrapper {body: [...]}', () {
      final result = ResponseMapper.tryExtractBodyList({
        'body': [1, 2, 3],
        'message': 'OK',
      });
      expect(result, [1, 2, 3]);
    });

    test('retourne la liste telle quelle si déjà à plat', () {
      expect(ResponseMapper.tryExtractBodyList([4, 5]), [4, 5]);
    });

    test('retourne null si body n\'est pas une liste', () {
      expect(ResponseMapper.tryExtractBodyList({'body': {'id': 1}}), isNull);
      expect(ResponseMapper.tryExtractBodyList('texte'), isNull);
    });
  });

  group('ResponseMapper.extractBody (PRA-02, variante stricte)', () {
    test('extrait le body du wrapper', () {
      expect(
        ResponseMapper.extractBody({'body': {'id': 1}}),
        {'id': 1},
      );
    });

    test('lance CustomException si data inexploitable', () {
      expect(
        () => ResponseMapper.extractBody('texte'),
        throwsA(isA<Object>()),
      );
    });
  });
}
