import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';

void main() {
  group('AppartementTypeLocation.fromBackend', () {
    test('valeurs strictes reconnues', () {
      expect(AppartementTypeLocation.fromBackend('STUDIO'),
          AppartementTypeLocation.studio);
      expect(AppartementTypeLocation.fromBackend('DEUX_PIECES'),
          AppartementTypeLocation.deuxPieces);
      expect(AppartementTypeLocation.fromBackend('TROIS_PIECES'),
          AppartementTypeLocation.troisPieces);
      expect(AppartementTypeLocation.fromBackend('QUATRE_PIECES'),
          AppartementTypeLocation.quatrePieces);
      expect(AppartementTypeLocation.fromBackend('CINQ_PLUS'),
          AppartementTypeLocation.cinqPlus);
    });

    test('null ou vide → null', () {
      expect(AppartementTypeLocation.fromBackend(null), isNull);
      expect(AppartementTypeLocation.fromBackend(''), isNull);
    });

    test('chaîne inconnue → fallback fromLegacy (default deuxPieces)', () {
      expect(AppartementTypeLocation.fromBackend('Une valeur exotique'),
          AppartementTypeLocation.deuxPieces);
    });
  });

  group('AppartementTypeLocation.fromLegacy — matching direct', () {
    test('« Studio » insensible casse', () {
      expect(AppartementTypeLocation.fromLegacy('Studio', null),
          AppartementTypeLocation.studio);
      expect(AppartementTypeLocation.fromLegacy('studio', 99),
          AppartementTypeLocation.studio);
      expect(AppartementTypeLocation.fromLegacy('STUDIO', 0),
          AppartementTypeLocation.studio);
    });

    test('« 2 pièces » et variantes', () {
      expect(AppartementTypeLocation.fromLegacy('2 pièces', null),
          AppartementTypeLocation.deuxPieces);
      expect(AppartementTypeLocation.fromLegacy('2p', null),
          AppartementTypeLocation.deuxPieces);
    });

    test('« 3 pièces » → troisPieces', () {
      expect(AppartementTypeLocation.fromLegacy('3 pièces', null),
          AppartementTypeLocation.troisPieces);
    });

    test('« 4 pièces » → quatrePieces', () {
      expect(AppartementTypeLocation.fromLegacy('4 pièces', null),
          AppartementTypeLocation.quatrePieces);
    });

    test('« 5+ pièces » → cinqPlus', () {
      expect(AppartementTypeLocation.fromLegacy('5+ pièces', null),
          AppartementTypeLocation.cinqPlus);
      expect(AppartementTypeLocation.fromLegacy('5+', null),
          AppartementTypeLocation.cinqPlus);
    });
  });

  group('AppartementTypeLocation.fromLegacy — dérivation depuis nbChambres', () {
    test('« Chambre privée » avec nbChambres=2 → troisPieces', () {
      expect(AppartementTypeLocation.fromLegacy('Chambre privée', 2),
          AppartementTypeLocation.troisPieces);
    });

    test('« Appartement entier » avec nbChambres=4 → cinqPlus', () {
      expect(AppartementTypeLocation.fromLegacy('Appartement entier', 4),
          AppartementTypeLocation.cinqPlus);
    });

    test('« Appartement entier » avec nbChambres=3 → quatrePieces', () {
      expect(AppartementTypeLocation.fromLegacy('Appartement entier', 3),
          AppartementTypeLocation.quatrePieces);
    });

    test('null + null → default deuxPieces', () {
      expect(AppartementTypeLocation.fromLegacy(null, null),
          AppartementTypeLocation.deuxPieces);
    });

    test('null + nbChambres=0 → default deuxPieces', () {
      expect(AppartementTypeLocation.fromLegacy(null, 0),
          AppartementTypeLocation.deuxPieces);
    });

    test('null + nbChambres=1 → deuxPieces', () {
      expect(AppartementTypeLocation.fromLegacy(null, 1),
          AppartementTypeLocation.deuxPieces);
    });

    test('null + nbChambres=5 → cinqPlus', () {
      expect(AppartementTypeLocation.fromLegacy(null, 5),
          AppartementTypeLocation.cinqPlus);
    });
  });

  group('AppartementTypeLocation — getters', () {
    test('label', () {
      expect(AppartementTypeLocation.studio.label, 'Studio');
      expect(AppartementTypeLocation.deuxPieces.label, '2 pièces');
      expect(AppartementTypeLocation.troisPieces.label, '3 pièces');
      expect(AppartementTypeLocation.quatrePieces.label, '4 pièces');
      expect(AppartementTypeLocation.cinqPlus.label, '5+ pièces');
    });

    test('derivedNbChambres', () {
      expect(AppartementTypeLocation.studio.derivedNbChambres, 1);
      expect(AppartementTypeLocation.deuxPieces.derivedNbChambres, 1);
      expect(AppartementTypeLocation.troisPieces.derivedNbChambres, 2);
      expect(AppartementTypeLocation.quatrePieces.derivedNbChambres, 3);
      expect(AppartementTypeLocation.cinqPlus.derivedNbChambres, isNull);
    });

    test('requiresFreeChambresInput', () {
      expect(AppartementTypeLocation.studio.requiresFreeChambresInput, isFalse);
      expect(AppartementTypeLocation.deuxPieces.requiresFreeChambresInput,
          isFalse);
      expect(AppartementTypeLocation.troisPieces.requiresFreeChambresInput,
          isFalse);
      expect(AppartementTypeLocation.quatrePieces.requiresFreeChambresInput,
          isFalse);
      expect(
          AppartementTypeLocation.cinqPlus.requiresFreeChambresInput, isTrue);
    });

    test('value', () {
      expect(AppartementTypeLocation.studio.value, 'STUDIO');
      expect(AppartementTypeLocation.deuxPieces.value, 'DEUX_PIECES');
      expect(AppartementTypeLocation.troisPieces.value, 'TROIS_PIECES');
      expect(AppartementTypeLocation.quatrePieces.value, 'QUATRE_PIECES');
      expect(AppartementTypeLocation.cinqPlus.value, 'CINQ_PLUS');
    });
  });
}
