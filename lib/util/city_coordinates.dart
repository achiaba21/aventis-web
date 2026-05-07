import 'package:latlong2/latlong.dart';

/// Utilitaire pour obtenir les coordonnées GPS des villes de Côte d'Ivoire
/// Utilisé comme fallback quand les coordonnées exactes sont masquées
class CityCoordinates {
  static const Map<String, List<double>> _cities = {
    // Principales villes
    'Abidjan': [5.3600, -4.0083],
    'Bouaké': [7.6833, -5.0333],
    'Yamoussoukro': [6.8276, -5.2893],
    'San-Pédro': [4.7500, -6.6333],
    'Korhogo': [9.4500, -5.6333],
    'Daloa': [6.8775, -6.4502],
    'Man': [7.4125, -7.5536],
    'Gagnoa': [6.1319, -5.9506],
    'Divo': [5.8372, -5.3572],
    'Abengourou': [6.7297, -3.4964],

    // Communes d'Abidjan
    'Cocody': [5.3486, -3.9878],
    'Plateau': [5.3167, -4.0167],
    'Marcory': [5.3000, -3.9833],
    'Treichville': [5.2833, -4.0000],
    'Koumassi': [5.2833, -3.9500],
    'Port-Bouët': [5.2500, -3.9333],
    'Yopougon': [5.3333, -4.0833],
    'Abobo': [5.4167, -4.0167],
    'Adjamé': [5.3667, -4.0333],
    'Attécoubé': [5.3333, -4.0500],
    'Bingerville': [5.3500, -3.8833],
    'Songon': [5.3167, -4.2667],
    'Anyama': [5.4833, -4.0500],

    // Autres villes importantes
    'Bassam': [5.2000, -3.7333],
    'Grand-Bassam': [5.2000, -3.7333],
    'Assinie': [5.1500, -3.4667],
    'Jacqueville': [5.2000, -4.4167],
    'Dabou': [5.3167, -4.3833],
    'Agboville': [5.9333, -4.2167],
    'Adzopé': [6.1000, -3.8500],
    'Bondoukou': [8.0333, -2.8000],
    'Ferkessédougou': [9.5833, -5.2000],
    'Odienné': [9.5000, -7.5667],
    'Séguéla': [7.9500, -6.6667],
    'Dimbokro': [6.6500, -4.7000],
    'Toumodi': [6.5500, -5.0167],
    'Lakota': [5.8500, -5.6833],
    'Soubré': [5.7833, -6.6000],
    'Duékoué': [6.7333, -7.3500],
    'Guiglo': [6.5333, -7.4833],
    'Tabou': [4.4167, -7.3500],
    'Sassandra': [4.9500, -6.0833],
  };

  /// Coordonnées par défaut (Abidjan centre)
  static const LatLng defaultLocation = LatLng(5.3600, -4.0083);

  /// Zoom par défaut pour une vue ville
  static const double defaultZoom = 12.0;

  /// Zoom pour une vue quartier/commune
  static const double neighborhoodZoom = 14.0;

  /// Retourne les coordonnées d'une ville par son nom
  /// Retourne les coordonnées d'Abidjan par défaut si ville non trouvée
  static LatLng getCoordinates(String? cityName) {
    if (cityName == null || cityName.isEmpty) {
      return defaultLocation;
    }

    // Recherche exacte
    final coords = _cities[cityName];
    if (coords != null) {
      return LatLng(coords[0], coords[1]);
    }

    // Recherche insensible à la casse
    final lowerName = cityName.toLowerCase();
    for (final entry in _cities.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return LatLng(entry.value[0], entry.value[1]);
      }
    }

    // Recherche partielle (contient)
    for (final entry in _cities.entries) {
      if (entry.key.toLowerCase().contains(lowerName) ||
          lowerName.contains(entry.key.toLowerCase())) {
        return LatLng(entry.value[0], entry.value[1]);
      }
    }

    return defaultLocation;
  }

  /// Vérifie si une ville est connue
  static bool isKnownCity(String? cityName) {
    if (cityName == null || cityName.isEmpty) return false;

    final lowerName = cityName.toLowerCase();
    return _cities.keys.any((key) => key.toLowerCase() == lowerName);
  }
}
