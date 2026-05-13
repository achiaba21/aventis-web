import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/model/appartement/appartement_backend_mapper.dart';

/// Tests post-migration 2026-05-13 : le payload est désormais **flat**
/// (plus de shape `residence` virtuelle), seul `geoLat/geoLongi` sont
/// retirés de l'address au create/update car calculés serveur.
Appartement _appart({String? titre, Address? address, double? prix}) {
  return Appartement(
    titre: titre,
    address: address,
    prix: prix,
  );
}

Address _address({double? geoLat, double? geoLongi, String? nom}) {
  final a = Address();
  a.geoLat = geoLat;
  a.geoLongi = geoLongi;
  a.nom = nom;
  return a;
}

void main() {
  final mapper = AppartementBackendMapper.instance;

  group('AppartementBackendMapper.toCreatePayload', () {
    test('sans address → payload sans shape résidence', () {
      final appart = _appart(titre: 'Loft Plateau', prix: 65000);
      final payload = mapper.toCreatePayload(appart);

      expect(payload.containsKey('residence'), isFalse,
          reason: 'Plus de shape résidence depuis migration backend');
      expect(payload['titre'], 'Loft Plateau');
      expect(payload['prix'], 65000);
    });

    test('avec address → address racine présente, geoLat/geoLongi retirés', () {
      final address = _address(
        geoLat: 5.31,
        geoLongi: -4.02,
        nom: 'Quartier centre',
      );
      final appart = _appart(titre: 'Studio', address: address);
      final payload = mapper.toCreatePayload(appart);

      expect(payload['address'], isA<Map>());
      final addrMap = payload['address'] as Map;
      expect(addrMap.containsKey('geoLat'), isFalse,
          reason: 'geoLat est calculé backend, ne doit pas être envoyé');
      expect(addrMap.containsKey('geoLongi'), isFalse,
          reason: 'geoLongi est calculé backend, ne doit pas être envoyé');
      expect(addrMap['nom'], 'Quartier centre');
    });

    test('id absent du payload à la création', () {
      final appart = _appart(titre: 'Test');
      final payload = mapper.toCreatePayload(appart);
      expect(payload['id'], isNull);
    });
  });

  group('AppartementBackendMapper.toUpdatePayload', () {
    test('backendResidenceId ignoré (compat ascendante)', () {
      final appart = _appart(titre: 'Studio Cocody');
      final payload = mapper.toUpdatePayload(appart, backendResidenceId: 42);

      expect(payload.containsKey('residence'), isFalse);
      expect(payload.containsKey('residenceId'), isFalse);
      expect(payload['titre'], 'Studio Cocody');
    });

    test('payload flat identique au create', () {
      final address = _address(geoLat: 1, geoLongi: 2, nom: 'X');
      final appart = _appart(titre: 'Sans id', address: address);
      final payload = mapper.toUpdatePayload(appart);
      expect(payload['address'], isA<Map>());
      final addr = payload['address'] as Map;
      expect(addr.containsKey('geoLat'), isFalse);
      expect(addr.containsKey('geoLongi'), isFalse);
    });
  });

  group('AppartementBackendMapper.fromBackendDto', () {
    test('lit address racine du DTO flat', () {
      final json = <String, dynamic>{
        'id': 12,
        'titre': 'Bien moderne',
        'address': {
          'nom': 'Plateau',
        },
      };
      final appart = mapper.fromBackendDto(json);
      expect(appart.id, 12);
      expect(appart.titre, 'Bien moderne');
      expect(appart.address, isNotNull);
      expect(appart.address!.nom, 'Plateau');
    });

    test('fusion défensive residence.address (DTO legacy)', () {
      final json = <String, dynamic>{
        'id': 12,
        'titre': 'Bien legacy',
        'residence': {
          'id': 7,
          'address': {
            'nom': 'Plateau',
          },
        },
      };
      final appart = mapper.fromBackendDto(json);
      expect(appart.id, 12);
      // Le modèle Appartement.fromJson fait la fusion défensive depuis
      // residence.address tant qu'un caller envoie cette shape legacy.
      expect(appart.address?.nom, 'Plateau');
    });
  });

  group('AppartementBackendMapper.extractBackendResidenceId (deprecated)', () {
    test('depuis residence.id (fixture legacy)', () {
      // ignore: deprecated_member_use_from_same_package
      final id = mapper.extractBackendResidenceId({
        'residence': {'id': 99},
      });
      expect(id, 99);
    });

    test('depuis flat residenceId (fixture legacy)', () {
      // ignore: deprecated_member_use_from_same_package
      final id = mapper.extractBackendResidenceId({'residenceId': 77});
      expect(id, 77);
    });

    test('null si aucun des deux présents', () {
      // ignore: deprecated_member_use_from_same_package
      final id = mapper.extractBackendResidenceId({'id': 1, 'titre': 'X'});
      expect(id, isNull);
    });
  });
}
