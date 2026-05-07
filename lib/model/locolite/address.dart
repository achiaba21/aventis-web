import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/util/city_coordinates.dart';
import 'package:latlong2/latlong.dart';

class Address {
  int? id;
  double? lat;
  double? longi;
  double? geoLat;
  double? geoLongi;
  String? nom;
  Commune? commune;
  String? description;

  /// Vérifie si les coordonnées GPS exactes sont disponibles
  bool get hasExactLocation => lat != null && longi != null;

  /// Vérifie si les coordonnées géocodées sont disponibles
  bool get hasGeocodedLocation => geoLat != null && geoLongi != null;

  /// Retourne les coordonnées géocodées si disponibles
  LatLng? get geocodedLocation =>
      hasGeocodedLocation ? LatLng(geoLat!, geoLongi!) : null;

  /// Retourne les coordonnées à afficher (exactes si dispo, sinon géocodées, sinon fallback)
  LatLng? get displayLocation => exactLocation ?? geocodedLocation;

  /// Vérifie si une localisation de fallback est disponible (commune/ville)
  bool get hasFallbackLocation =>
      commune?.nom != null || commune?.ville?.nom != null;

  /// Retourne les coordonnées exactes si disponibles
  LatLng? get exactLocation => hasExactLocation ? LatLng(lat!, longi!) : null;

  /// Retourne les coordonnées de fallback (centre de la commune ou ville)
  LatLng get fallbackLocation {
    // Essayer d'abord la commune, puis la ville
    final locationName = commune?.nom ?? commune?.ville?.nom;
    return CityCoordinates.getCoordinates(locationName);
  }

  /// Retourne le nom de la localisation pour l'affichage
  String get locationDisplayName {
    if (commune?.nom != null && commune?.ville?.nom != null) {
      return '${commune!.nom}, ${commune!.ville!.nom}';
    }
    return commune?.nom ?? commune?.ville?.nom ?? 'Localisation inconnue';
  }

  Address({
    this.id,
    this.lat,
    this.longi,
    this.geoLat,
    this.geoLongi,
    this.nom,
    this.commune,
    this.description,
  });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    longi = json['longi'];
    geoLat = json['geoLat'];
    geoLongi = json['geoLongi'];
    nom = json['nom'];
    commune =
        json['commune'] != null ? Commune.fromJson(json['commune']) : null;
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['longi'] = longi;
    data['geoLat'] = geoLat;
    data['geoLongi'] = geoLongi;
    data['nom'] = nom;
    if (commune != null) {
      data['commune'] = commune!.toJson();
    }
    data['description'] = description;
    return data;
  }

  @override
  String toString() {
    return 'Address{id: $id, lat: $lat, longi: $longi, nom: $nom, description: $description}';
  }
}
