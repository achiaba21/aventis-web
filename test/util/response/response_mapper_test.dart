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
}
