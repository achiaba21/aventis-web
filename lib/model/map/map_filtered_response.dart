import 'package:asfar/model/map/map_appartement.dart';

/// Wrapper de la réponse `GET /api/map/appartements/filtered`.
///
/// Tolère deux formats backend pour faciliter la transition R-BACK2 :
///   - **Ancien** (List directe) : `[{...}, {...}]` → `zoneName` null
///   - **Nouveau** (wrapper) : `{"appartements": [...], "zoneName": "Cocody"}`
///
/// Le `zoneName` (reverse geocode côté backend) alimente le `MapZoneBanner`
/// — "23 résidences à Cocody Riviera". Si null, fallback "dans cette zone".
class MapFilteredResponse {
  final List<MapAppartement> appartements;
  final String? zoneName;

  const MapFilteredResponse({
    required this.appartements,
    this.zoneName,
  });

  factory MapFilteredResponse.fromJson(dynamic json) {
    if (json is List) {
      final parsed = json
          .map((e) => MapAppartement.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapFilteredResponse(appartements: parsed);
    }
    if (json is Map<String, dynamic>) {
      final list = (json['appartements'] as List?) ?? const [];
      final parsed = list
          .map((e) => MapAppartement.fromJson(e as Map<String, dynamic>))
          .toList();
      return MapFilteredResponse(
        appartements: parsed,
        zoneName: json['zoneName'] as String?,
      );
    }
    return const MapFilteredResponse(appartements: []);
  }
}
