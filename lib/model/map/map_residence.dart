import 'package:latlong2/latlong.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/proprietaire.dart';

/// Formate une plage de prix en FCFA
String formatPriceRange(double? minPrice, double? maxPrice) {
  if (minPrice == null || maxPrice == null) return 'Prix non disponible';
  if (minPrice == maxPrice) return '${minPrice.toInt()} FCFA';
  return '${minPrice.toInt()} - ${maxPrice.toInt()} FCFA';
}

class MapResidence {
  int? id;
  String? nom;
  String? reference;

  // Coordonnées obfusquées pour l'affichage sur la carte
  double? displayLat;
  double? displayLongi;

  // Coordonnées réelles (optionnelles, pour navigation précise)
  double? realLat;
  double? realLongi;

  // Informations additionnelles pour la carte
  int? appartementCount;
  double? minPrice;
  double? maxPrice;
  String? priceRange;

  // Informations du propriétaire
  Proprietaire? proprietaire;

  // Adresse (sans coordonnées exactes)
  String? communeName;
  String? addressDescription;

  MapResidence({
    this.id,
    this.nom,
    this.reference,
    this.displayLat,
    this.displayLongi,
    this.realLat,
    this.realLongi,
    this.appartementCount,
    this.minPrice,
    this.maxPrice,
    this.priceRange,
    this.proprietaire,
    this.communeName,
    this.addressDescription,
  });

  MapResidence.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    reference = json['reference'];
    displayLat = json['displayLat']?.toDouble();
    displayLongi = json['displayLongi']?.toDouble();
    realLat = json['realLat']?.toDouble();
    realLongi = json['realLongi']?.toDouble();
    appartementCount = json['appartementCount'];
    minPrice = json['minPrice']?.toDouble();
    maxPrice = json['maxPrice']?.toDouble();
    priceRange = json['priceRange'];
    proprietaire = json['proprietaire'] != null
        ? Proprietaire.fromJson(json['proprietaire'])
        : null;
    communeName = json['communeName'];
    addressDescription = json['addressDescription'];
  }

  /// Crée un MapResidence depuis un Appartement (modèle plat).
  ///
  /// Depuis la refonte BACKEND-FLAT-APPART, chaque pin sur la carte représente
  /// un appartement individuel. Le nom "MapResidence" est conservé pour ne
  /// pas casser le reste du code (clusters, websocket, etc.) — il joue le
  /// rôle d'un "pin" générique.
  factory MapResidence.fromAppartement(Appartement appart) {
    final address = appart.address;
    return MapResidence(
      id: appart.id,
      nom: appart.titre,
      displayLat: address?.lat,
      displayLongi: address?.longi,
      appartementCount: 1,
      minPrice: appart.prix,
      maxPrice: appart.prix,
      communeName: address?.commune?.nom,
      addressDescription: address?.description ?? address?.locationDisplayName,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['reference'] = reference;
    data['displayLat'] = displayLat;
    data['displayLongi'] = displayLongi;
    data['realLat'] = realLat;
    data['realLongi'] = realLongi;
    data['appartementCount'] = appartementCount;
    data['minPrice'] = minPrice;
    data['maxPrice'] = maxPrice;
    data['priceRange'] = priceRange;
    if (proprietaire != null) {
      data['proprietaire'] = proprietaire!.toJson();
    }
    data['communeName'] = communeName;
    data['addressDescription'] = addressDescription;
    return data;
  }

  // Getters utilitaires
  LatLng get displayPosition => LatLng(displayLat ?? 0, displayLongi ?? 0);
  LatLng? get realPosition => (realLat != null && realLongi != null)
      ? LatLng(realLat!, realLongi!)
      : null;

  bool get hasValidDisplayCoordinates => displayLat != null && displayLongi != null;

  String get formattedPriceRange => formatPriceRange(minPrice, maxPrice);

  String get apartmentCountText {
    if (appartementCount == null || appartementCount == 0) return 'Aucun appartement';
    if (appartementCount == 1) return '1 appartement';
    return '$appartementCount appartements';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapResidence && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MapResidence{id: $id, nom: $nom, displayLat: $displayLat, displayLongi: $displayLongi, appartementCount: $appartementCount}';
  }
}

/// Représente un cluster de résidences sur la carte
/// Regroupe plusieurs résidences proches pour un affichage agrégé
class MapCluster {
  final List<MapResidence> residences;
  final LatLng center;
  final double radius;

  MapCluster({
    required this.residences,
    required this.center,
    required this.radius,
  });

  int get totalApartments => residences.fold(0, (sum, r) => sum + (r.appartementCount ?? 0));

  double? get minPrice {
    final prices = residences.where((r) => r.minPrice != null).map((r) => r.minPrice!);
    return prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
  }

  double? get maxPrice {
    final prices = residences.where((r) => r.maxPrice != null).map((r) => r.maxPrice!);
    return prices.isEmpty ? null : prices.reduce((a, b) => a > b ? a : b);
  }

  String get formattedPriceRange => formatPriceRange(minPrice, maxPrice);
}