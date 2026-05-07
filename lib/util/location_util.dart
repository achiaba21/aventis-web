import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/util/function.dart';

/// Utilitaire pour gérer la géolocalisation
class LocationUtil {
  /// Vérifie et demande les permissions de localisation
  ///
  /// Retourne:
  /// - [bool] : true si les permissions sont accordées, false sinon
  static Future<bool> checkAndRequestPermissions() async {
    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        deboger("Service de localisation désactivé");
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          deboger("Permission de localisation refusée");
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        deboger("Permission de localisation refusée définitivement");
        return false;
      }

      return true;
    } catch (e) {
      deboger("Erreur lors de la vérification des permissions: $e");
      return false;
    }
  }

  /// Récupère la position actuelle de l'utilisateur
  ///
  /// Retourne:
  /// - [Position?] : La position actuelle ou null en cas d'erreur
  static Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier les permissions d'abord
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        return null;
      }

      // Récupérer la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      deboger("Position récupérée: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      deboger("Erreur lors de la récupération de la position: $e");
      return null;
    }
  }

  /// Convertit une Position en LatLng
  ///
  /// Paramètres:
  /// - [position] : La position à convertir
  ///
  /// Retourne:
  /// - [LatLng] : Les coordonnées converties
  static LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Récupère la position actuelle sous forme de LatLng
  ///
  /// Retourne:
  /// - [LatLng?] : Les coordonnées actuelles ou null en cas d'erreur
  static Future<LatLng?> getCurrentLatLng() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return positionToLatLng(position);
  }

  /// Calcule la distance entre deux positions en mètres
  ///
  /// Paramètres:
  /// - [start] : Position de départ
  /// - [end] : Position d'arrivée
  ///
  /// Retourne:
  /// - [double] : La distance en mètres
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Formate une distance en texte lisible
  ///
  /// Paramètres:
  /// - [distanceInMeters] : Distance en mètres
  ///
  /// Retourne:
  /// - [String] : Distance formatée (ex: "1.5 km" ou "500 m")
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)} m";
    } else {
      return "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
    }
  }

  /// Obtient le message d'erreur approprié selon le statut de permission
  ///
  /// Retourne:
  /// - [String?] : Message d'erreur ou null si tout va bien
  static Future<String?> getPermissionErrorMessage() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Le service de localisation est désactivé. Veuillez l'activer dans les paramètres.";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return "Permission de localisation refusée.";
    }

    if (permission == LocationPermission.deniedForever) {
      return "Permission de localisation refusée définitivement. Veuillez l'activer dans les paramètres.";
    }

    return null;
  }
}
