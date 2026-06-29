import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/util/url/share_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildAppartementShareUrl', () {
    test('construit {domain}/share/{token}', () {
      const token = '9f2c4e7a1b8d4f60a3c5e1d27b9a0f3c';
      final url = buildAppartementShareUrl(token);

      expect(url, '$domain/share/$token');
      expect(url, endsWith('/share/$token'));
      expect(url.startsWith('http'), isTrue);
      // Un seul `/share/` (pas de double slash domaine↔chemin ; le `//` du
      // schéma http(s):// n'est pas matché).
      expect('/share/'.allMatches(url).length, 1);
    });

    test('token vide → URL formée (la garde null vit dans le bouton)', () {
      expect(buildAppartementShareUrl(''), '$domain/share/');
    });
  });
}
