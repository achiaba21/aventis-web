import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/model/appartement/appartement_backend_mapper.dart';

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
    test('sans address → residence shape minimale, address absente du root', () {
      final appart = _appart(titre: 'Loft Plateau', prix: 65000);
      final payload = mapper.toCreatePayload(appart);

      expect(payload['address'], isNull);
      expect(payload['residence'], isA<Map>());
      expect(payload['residence']['nom'], isNotNull);
      expect(payload['residence'].containsKey('address'), isFalse);
      expect(payload['titre'], 'Loft Plateau');
      expect(payload['prix'], 65000);
    });

    test('avec address → embarquée dans residence + geoLat/geoLongi retirés', () {
      final address = _address(
        geoLat: 5.31,
        geoLongi: -4.02,
        nom: 'Quartier centre',
      );
      final appart = _appart(titre: 'Studio', address: address);
      final payload = mapper.toCreatePayload(appart);

      expect(payload['address'], isNull);
      expect(payload['residence']['address'], isA<Map>());
      final addrMap = payload['residence']['address'] as Map;
      expect(addrMap.containsKey('geoLat'), isFalse,
          reason: 'geoLat est calculé backend, ne doit pas être envoyé');
      expect(addrMap.containsKey('geoLongi'), isFalse,
          reason: 'geoLongi est calculé backend, ne doit pas être envoyé');
      expect(addrMap['nom'], 'Quartier centre');
    });

    test('residence shape sans id à la création (id absent)', () {
      final appart = _appart(titre: 'Test');
      final payload = mapper.toCreatePayload(appart);
      expect(payload['residence'].containsKey('id'), isFalse);
    });
  });

  group('AppartementBackendMapper.toUpdatePayload', () {
    test('avec backendResidenceId → id présent dans residence + au top-level', () {
      final appart = _appart(titre: 'Studio Cocody');
      final payload = mapper.toUpdatePayload(appart, backendResidenceId: 42);

      expect(payload['residence']['id'], 42);
      expect(payload['residenceId'], 42);
      expect(payload['address'], isNull);
    });

    test('sans backendResidenceId → id absent du residence shape', () {
      final appart = _appart(titre: 'Sans id');
      final payload = mapper.toUpdatePayload(appart);
      expect(payload['residence'].containsKey('id'), isFalse);
      expect(payload.containsKey('residenceId'), isFalse);
    });
  });

  group('AppartementBackendMapper.fromBackendDto', () {
    test('fusionne residence.address → appart.address', () {
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
      expect(appart.titre, 'Bien legacy');
      expect(appart.address, isNotNull);
      expect(appart.address!.nom, 'Plateau');
    });

    test('retire residence et residenceId du JSON parsé', () {
      final json = <String, dynamic>{
        'id': 1,
        'titre': 'X',
        'residence': {'id': 9, 'address': {'nom': 'C'}},
        'residenceId': 9,
      };
      final appart = mapper.fromBackendDto(json);
      // L'appart parsé ne doit pas porter ces champs (ils ne sont pas du modèle).
      expect(appart.toJson().containsKey('residence'), isFalse);
      expect(appart.toJson().containsKey('residenceId'), isFalse);
    });
  });

  group('AppartementBackendMapper.extractBackendResidenceId', () {
    test('depuis residence.id', () {
      final id = mapper.extractBackendResidenceId({
        'residence': {'id': 99},
      });
      expect(id, 99);
    });

    test('depuis flat residenceId', () {
      final id = mapper.extractBackendResidenceId({'residenceId': 77});
      expect(id, 77);
    });

    test('null si aucun des deux présents', () {
      final id = mapper.extractBackendResidenceId({'id': 1, 'titre': 'X'});
      expect(id, isNull);
    });
  });
}
