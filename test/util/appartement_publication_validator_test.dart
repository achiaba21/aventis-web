import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/appartement_publication_validator.dart';

/// Construit un Appartement « presque valide » que chaque test ajuste.
Appartement _validBase({
  AppartementTypeLocation? type = AppartementTypeLocation.deuxPieces,
  int? nbChambres = 1,
  int? nbLits = 2,
  int? nbDouches = 1,
  double? prix = 50000,
}) {
  return Appartement(
    titre: 'Loft Plateau',
    address: Address(lat: 5.32, longi: -4.02),
    typeLocation: type,
    nbChambres: nbChambres,
    nbLits: nbLits,
    nbDouches: nbDouches,
    prix: prix,
    photos: [
      PhotoAppart(path: 'p1.jpg'),
      PhotoAppart(path: 'p2.jpg'),
      PhotoAppart(path: 'p3.jpg'),
    ],
  );
}

void main() {
  final validator = AppartementPublicationValidator.instance;

  group('Validator — base valide', () {
    test('appartement complet et cohérent → valide', () {
      final result = validator.validate(_validBase());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });
  });

  group('Validator — typeLocation', () {
    test('typeLocation null → invalide', () {
      final result = validator.validate(_validBase(type: null));
      expect(result.isValid, isFalse);
      expect(result.errors.containsKey('typeLocation'), isTrue);
    });
  });

  group('Validator — cohérence type ↔ chambres', () {
    test('Studio + nbChambres=1 → valide', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.studio,
        nbChambres: 1,
      ));
      expect(result.isValid, isTrue);
    });

    test('Studio + nbChambres=2 → invalide', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.studio,
        nbChambres: 2,
      ));
      expect(result.isValid, isFalse);
      expect(result.errors['nbChambres'], contains('Studio'));
    });

    test('3 pièces + nbChambres=2 → valide', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.troisPieces,
        nbChambres: 2,
      ));
      expect(result.isValid, isTrue);
    });

    test('3 pièces + nbChambres=3 → invalide', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.troisPieces,
        nbChambres: 3,
      ));
      expect(result.isValid, isFalse);
      expect(result.errors['nbChambres'], contains('3 pièces'));
    });

    test('5+ pièces + nbChambres=4 → valide', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.cinqPlus,
        nbChambres: 4,
      ));
      expect(result.isValid, isTrue);
    });

    test('5+ pièces + nbChambres=3 → invalide (< 4)', () {
      final result = validator.validate(_validBase(
        type: AppartementTypeLocation.cinqPlus,
        nbChambres: 3,
      ));
      expect(result.isValid, isFalse);
      expect(result.errors['nbChambres'], contains('5+'));
    });
  });

  group('Validator — autres règles', () {
    test('nbChambres null → invalide', () {
      final result = validator.validate(_validBase(nbChambres: null));
      expect(result.isValid, isFalse);
      expect(result.errors['nbChambres'], contains('1 chambre'));
    });

    test('nbChambres = 0 → invalide', () {
      final result = validator.validate(_validBase(nbChambres: 0));
      expect(result.isValid, isFalse);
      expect(result.errors['nbChambres'], contains('1 chambre'));
    });
  });
}
