import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/util/type_location_chambres_policy.dart';

void main() {
  group('TypeLocationChambresPolicy.resolveNbChambres', () {
    test('Studio force toujours à 1', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.studio, null),
          1);
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.studio, 5),
          1);
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.studio, 0),
          1);
    });

    test('2P force à 1, 3P à 2, 4P à 3', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.deuxPieces, null),
          1);
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.troisPieces, null),
          2);
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.quatrePieces, null),
          3);
    });

    test('5+ avec current null → 4 (min)', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.cinqPlus, null),
          4);
    });

    test('5+ avec current=6 → 6 (préserve)', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.cinqPlus, 6),
          6);
    });

    test('5+ avec current=2 → 4 (force au min)', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.cinqPlus, 2),
          4);
    });

    test('5+ avec current=4 → 4 (préserve)', () {
      expect(
          TypeLocationChambresPolicy.resolveNbChambres(
              AppartementTypeLocation.cinqPlus, 4),
          4);
    });
  });

  group('TypeLocationChambresPolicy.isCoherent', () {
    test('Studio + 1 → true ; Studio + 2 → false ; Studio + null → false', () {
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.studio, 1),
          isTrue);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.studio, 2),
          isFalse);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.studio, null),
          isFalse);
    });

    test('3 pièces + 2 → true ; 3 pièces + 3 → false', () {
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.troisPieces, 2),
          isTrue);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.troisPieces, 3),
          isFalse);
    });

    test('5+ accepte ≥ 4 ; refuse < 4', () {
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.cinqPlus, 4),
          isTrue);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.cinqPlus, 10),
          isTrue);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.cinqPlus, 3),
          isFalse);
      expect(
          TypeLocationChambresPolicy.isCoherent(
              AppartementTypeLocation.cinqPlus, 0),
          isFalse);
    });
  });
}
