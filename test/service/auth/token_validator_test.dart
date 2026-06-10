import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/service/auth/token_validator.dart';

/// Fabrique un JWT non signé avec le payload donné.
///
/// JwtDecoder ne vérifie pas la signature : une signature factice suffit
/// pour tester la logique d'expiration.
String _makeJwt(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(jsonEncode(map))).replaceAll('=', '');
  final header = encode({'alg': 'HS256', 'typ': 'JWT'});
  final body = encode(payload);
  return '$header.$body.fake-signature';
}

void main() {
  group('TokenValidator.isValid', () {
    test('retourne false pour un jeton null', () {
      expect(TokenValidator.isValid(null), isFalse);
    });

    test('retourne false pour un jeton vide', () {
      expect(TokenValidator.isValid(''), isFalse);
    });

    test('retourne false pour un jeton malformé (pas un JWT)', () {
      expect(TokenValidator.isValid('abc'), isFalse);
      expect(TokenValidator.isValid('a.b.c'), isFalse);
    });

    test('retourne false pour un jeton expiré', () {
      final exp = DateTime.now()
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch ~/
          1000;
      final token = _makeJwt({'sub': 'user', 'exp': exp});
      expect(TokenValidator.isValid(token), isFalse);
    });

    test('retourne true pour un jeton non expiré', () {
      final exp = DateTime.now()
              .add(const Duration(hours: 1))
              .millisecondsSinceEpoch ~/
          1000;
      final token = _makeJwt({'sub': 'user', 'exp': exp});
      expect(TokenValidator.isValid(token), isTrue);
    });

    test('retourne false pour un jeton sans date d\'expiration', () {
      final token = _makeJwt({'sub': 'user'});
      expect(TokenValidator.isValid(token), isFalse);
    });
  });
}
