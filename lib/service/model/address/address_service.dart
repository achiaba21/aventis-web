import 'package:dio/dio.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/geocoding/geocoding_service.dart';
import 'package:asfar/util/function.dart';

class AddressService {
  static AddressService? _instance;
  final DioRequest _dioRequest = DioRequest.instance;
  final GeocodingService _geocodingService = GeocodingService.instance;

  static AddressService get instance {
    _instance ??= AddressService._internal();
    return _instance!;
  }

  AddressService._internal();

  /// Met à jour les coordonnées géocodées d'une adresse sur le serveur
  Future<bool> updateGeocodedCoordinates(
    int addressId,
    double geoLat,
    double geoLongi,
  ) async {
    try {
      final response = await _dioRequest.patch(
        '$domain/addresses/$addressId/geocode',
        data: {
          'geoLat': geoLat,
          'geoLongi': geoLongi,
        },
      );

      if (response.statusCode == 200) {
        deboger('AddressService: Coordonnées géocodées mises à jour pour address $addressId');
        return true;
      }
      return false;
    } on DioException catch (e) {
      deboger('AddressService.updateGeocodedCoordinates error: ${e.message}');
      return false;
    } catch (e) {
      deboger('AddressService.updateGeocodedCoordinates error: $e');
      return false;
    }
  }

  /// Géocode une adresse et sauvegarde le résultat sur le serveur
  /// Retourne l'adresse mise à jour ou l'adresse originale si échec
  Future<Address> geocodeAndSave(Address address) async {
    if (address.id == null) {
      deboger('AddressService.geocodeAndSave: Address sans id, impossible de sauvegarder');
      return address;
    }

    // Si déjà géocodé, ne rien faire
    if (address.hasGeocodedLocation) {
      return address;
    }

    // Géocoder l'adresse
    final coords = await _geocodingService.geocodeAddress(address);
    if (coords == null) {
      deboger('AddressService.geocodeAndSave: Géocodage échoué pour ${address.nom}');
      return address;
    }

    // Mettre à jour localement
    address.geoLat = coords.latitude;
    address.geoLongi = coords.longitude;

    // Sauvegarder sur le serveur
    await updateGeocodedCoordinates(
      address.id!,
      coords.latitude,
      coords.longitude,
    );

    return address;
  }

  /// Géocode une adresse sans sauvegarder (pour preview)
  Future<Address> geocodeOnly(Address address) async {
    if (address.hasGeocodedLocation) {
      return address;
    }

    final coords = await _geocodingService.geocodeAddress(address);
    if (coords != null) {
      address.geoLat = coords.latitude;
      address.geoLongi = coords.longitude;
    }

    return address;
  }

}
