import 'package:latlong2/latlong.dart';

/// Détails d'adresse extraits de la réponse Nominatim
class GeocodingAddress {
  final String? suburb; // Commune/Quartier
  final String? city; // Ville
  final String? state; // Région/État
  final String? country; // Pays
  final String? countryCode; // Code pays (ex: "ci")
  final String? postcode; // Code postal
  final String? road; // Rue
  final String? houseNumber; // Numéro

  GeocodingAddress({
    this.suburb,
    this.city,
    this.state,
    this.country,
    this.countryCode,
    this.postcode,
    this.road,
    this.houseNumber,
  });

  String? get street => "$city $suburb";

  factory GeocodingAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GeocodingAddress();
    return GeocodingAddress(
      suburb: json['suburb'] ?? json['neighbourhood'] ?? json['village'],
      city: json['city'] ?? json['town'] ?? json['municipality'],
      state: json['state'] ?? json['region'],
      country: json['country'],
      countryCode: json['country_code'],
      postcode: json['postcode'],
      road: json['road'] ?? json['street'],
      houseNumber: json['house_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suburb': suburb,
      'city': city,
      'state': state,
      'country': country,
      'country_code': countryCode,
      'postcode': postcode,
      'road': road,
      'house_number': houseNumber,
    };
  }

  @override
  String toString() {
    return 'GeocodingAddress{suburb: $suburb, city: $city, state: $state, country: $country}';
  }
}

/// Représente le résultat d'une requête de géocodage via l'API Nominatim.
///
/// Contient les coordonnées GPS (lat/lon) ainsi que des métadonnées
/// comme le nom d'affichage, le type de lieu et les détails d'adresse.
class GeocodingResult {
  final double lat;
  final double lon;
  final String displayName;
  final String? name; // Nom court du lieu
  final String? type;
  final String? addressType; // Type d'adresse (suburb, city, etc.)
  final double? importance;
  final GeocodingAddress? address; // Détails d'adresse
  final List<double>?
  boundingBox; // Zone géographique [south, north, west, east]

  GeocodingResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    this.name,
    this.type,
    this.addressType,
    this.importance,
    this.address,
    this.boundingBox,
  });

  LatLng get latLng => LatLng(lat, lon);

  /// Retourne la commune (suburb) si disponible
  String? get commune => address?.suburb;

  /// Retourne la ville si disponible
  String? get city => address?.city;

  /// Retourne la région/état si disponible
  String? get region => address?.state;

  /// Retourne le pays si disponible
  String? get country => address?.country;

  /// Retourne le code pays (ex: "ci" pour Côte d'Ivoire)
  String? get countryCode => address?.countryCode;

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    // Parser le boundingbox
    List<double>? bbox;
    if (json['boundingbox'] != null && json['boundingbox'] is List) {
      bbox =
          (json['boundingbox'] as List)
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList();
    }

    return GeocodingResult(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? '',
      name: json['name'],
      type: json['type'],
      addressType: json['addresstype'],
      importance:
          json['importance'] != null
              ? double.tryParse(json['importance'].toString())
              : null,
      address: GeocodingAddress.fromJson(json['address']),
      boundingBox: bbox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'display_name': displayName,
      'name': name,
      'type': type,
      'addresstype': addressType,
      'importance': importance,
      'address': address?.toJson(),
      'boundingbox': boundingBox,
    };
  }

  @override
  String toString() {
    return 'GeocodingResult{lat: $lat, lon: $lon, name: $name, commune: $commune, city: $city}';
  }
}
