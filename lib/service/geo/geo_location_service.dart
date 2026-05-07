import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:asfar/service/geocoding/geocoding_service.dart';
import 'package:asfar/util/function.dart';

/// Service de géolocalisation pour le wizard d'ajout d'appartement.
///
/// Agrège la gestion des permissions GPS, la récupération de la position
/// courante (avec timeout) et le reverse geocoding via [GeocodingService].
///
/// Toutes les opérations sont défensives : aucun appel ne lève une exception
/// en cas d'erreur — la méthode retourne `null` ou `false` selon le contrat.
class GeoLocationService {
  static GeoLocationService? _instance;

  /// Singleton instance.
  static GeoLocationService get instance {
    _instance ??= GeoLocationService._internal();
    return _instance!;
  }

  GeoLocationService._internal();

  /// Vérifie si l'application a la permission de localisation
  /// (et que le service système est activé).
  Future<bool> hasPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      deboger('GeoLocationService.hasPermission erreur: $e');
      return false;
    }
  }

  /// Demande la permission de localisation.
  ///
  /// Retourne `true` si la permission est accordée (always/whileInUse).
  /// Retourne `false` si refusée, refusée définitivement, ou si le service
  /// système est désactivé.
  Future<bool> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        deboger('GeoLocationService: service de localisation désactivé');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        deboger('GeoLocationService: permission refusée définitivement');
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      deboger('GeoLocationService.requestPermission erreur: $e');
      return false;
    }
  }

  /// Récupère la position GPS actuelle, ou `null` en cas de timeout / erreur /
  /// permission refusée.
  ///
  /// Le timeout par défaut est de 8 secondes — adapté au contexte du wizard
  /// où l'on ne veut pas bloquer l'utilisateur trop longtemps.
  Future<LatLng?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final granted = await hasPermission();
      if (!granted) {
        deboger('GeoLocationService.getCurrentLocation: permission absente');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).timeout(timeout);

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      deboger('GeoLocationService.getCurrentLocation erreur: $e');
      return null;
    }
  }

  /// Convertit des coordonnées GPS en adresse textuelle (display_name).
  ///
  /// Délègue à [GeocodingService.reverseGeocode] qui gère le rate limiting
  /// Nominatim (1 req/sec) et les timeouts. Retourne `null` en cas d'échec.
  Future<String?> reverseGeocode(LatLng position) {
    return GeocodingService.instance.reverseGeocode(position);
  }
}
