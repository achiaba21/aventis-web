import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/participant_mini.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filters.dart';
import 'package:asfar/util/calc/listing_map_filter.dart';

MapAppartement _mapAppart(int id) => MapAppartement(
      id: id,
      title: 'Logement $id',
      displayLat: 5.0,
      displayLongi: -4.0,
      price: 50000,
    );

Appartement _appart({
  required int id,
  AppartementTypeLocation? typeLocation,
  int? proprietaireId,
  String? communeNom,
}) {
  return Appartement(
    id: id,
    titre: 'Logement $id',
    typeLocation: typeLocation,
    proprietaire: proprietaireId != null
        ? ParticipantMini(
            id: proprietaireId,
            prenom: 'Proprio',
            nom: '$proprietaireId',
            telephone: '',
          )
        : null,
    communeNom: communeNom,
  );
}

void main() {
  group('ListingMapFilter — Filet de sécurité (cache vide ou partiel)', () {
    test('exclut un marker dont l\'id est absent du cache', () {
      final source = [_mapAppart(1), _mapAppart(2), _mapAppart(3)];
      final cache = {1: _appart(id: 1)}; // seul l'id 1 est connu

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: const ListingFilters(),
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('exclut un marker dont l\'id est null', () {
      final source = [MapAppartement(title: 'sans id'), _mapAppart(1)];
      final cache = {1: _appart(id: 1)};

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: const ListingFilters(),
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });
  });

  group('ListingMapFilter — Filtres actifs', () {
    test('filtre par typeLocation (multi-select OR)', () {
      final source = [_mapAppart(1), _mapAppart(2), _mapAppart(3)];
      final cache = {
        1: _appart(id: 1, typeLocation: AppartementTypeLocation.studio),
        2: _appart(id: 2, typeLocation: AppartementTypeLocation.deuxPieces),
        3: _appart(id: 3, typeLocation: AppartementTypeLocation.troisPieces),
      };
      const filters = ListingFilters(typeLocations: {
        AppartementTypeLocation.studio,
        AppartementTypeLocation.troisPieces,
      });

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: filters,
      );

      final ids = result.map((m) => m.id).toSet();
      expect(ids, {1, 3});
    });

    test('filtre par proprietaireId', () {
      final source = [_mapAppart(1), _mapAppart(2)];
      final cache = {
        1: _appart(id: 1, proprietaireId: 100),
        2: _appart(id: 2, proprietaireId: 200),
      };
      const filters = ListingFilters(proprietaireId: 100);

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: filters,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('filtre par communeNom', () {
      final source = [_mapAppart(1), _mapAppart(2)];
      final cache = {
        1: _appart(id: 1, communeNom: 'Cocody'),
        2: _appart(id: 2, communeNom: 'Yopougon'),
      };
      const filters = ListingFilters(communeNom: 'Cocody');

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: filters,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('combinaison AND : typeLocation + commune', () {
      final source = [_mapAppart(1), _mapAppart(2), _mapAppart(3)];
      final cache = {
        1: _appart(
            id: 1,
            typeLocation: AppartementTypeLocation.studio,
            communeNom: 'Cocody'),
        2: _appart(
            id: 2,
            typeLocation: AppartementTypeLocation.studio,
            communeNom: 'Yopougon'),
        3: _appart(
            id: 3,
            typeLocation: AppartementTypeLocation.deuxPieces,
            communeNom: 'Cocody'),
      };
      const filters = ListingFilters(
        typeLocations: {AppartementTypeLocation.studio},
        communeNom: 'Cocody',
      );

      final result = ListingMapFilter.apply(
        source: source,
        appartementsParId: cache,
        filters: filters,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });
  });
}
