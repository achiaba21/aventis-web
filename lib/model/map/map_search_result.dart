import 'package:latlong2/latlong.dart';

/// Résultat d'une recherche textuelle de lieu (geocoding backend Asfar).
///
/// Renvoyé par `MapService.searchPlace(String query)` via l'endpoint
/// `GET /api/map/search?q=...`. Sert à recentrer la carte sur la zone
/// cherchée par l'utilisateur (pattern `InteractiveMapPicker`).
class MapSearchResult {
  final double lat;
  final double lng;
  final String zoneName;
  final String formattedAddress;

  const MapSearchResult({
    required this.lat,
    required this.lng,
    required this.zoneName,
    required this.formattedAddress,
  });

  factory MapSearchResult.fromJson(Map<String, dynamic> json) {
    return MapSearchResult(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      zoneName: (json['zoneName'] as String?) ?? '',
      formattedAddress: (json['formattedAddress'] as String?) ?? '',
    );
  }

  LatLng get position => LatLng(lat, lng);
}
