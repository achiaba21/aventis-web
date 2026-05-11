import 'package:latlong2/latlong.dart';

/// Pin individuel d'un appartement sur la carte locataire — V9.7b.
///
/// Granularité : 1 marker = 1 appartement (la notion de "résidence" comme
/// groupe a été supprimée du domaine). Le marker affiche le prix unitaire.
///
/// Confidentialité (dual coordonnées) :
/// - `displayLat/displayLongi` : coordonnées **obfusquées** par le backend
///   (décalage calculé une fois à la création, stable entre appels), toujours
///   présentes en browse. Backend envoie ces champs sous les clés `lat`/`lng`
///   dans le payload `/api/map/appartements/filtered`.
/// - `realLat/realLongi` : coordonnées **réelles**, jamais exposées en browse.
///   Renseignées uniquement via l'endpoint `/real-location` lorsque le
///   locataire a une réservation au statut `PAYER` ou `FINALISER`.
///
/// `imgUrl` est inclus quand le backend le fournit dans `/filtered` — permet
/// d'éviter le lazy load du shimmer si la photo est déjà connue. Sinon le
/// `MapMarkerBottomSheet` la charge via `AppartementService.getAppartementById`.
///
/// Mapping JSON aligné sur les noms réels backend Asfar (`titre`, `prix`,
/// `typeLocation`, `lat`, `lng`, `imgUrl`) — voir `BACKEND_NOTES_MAP_V9_7B.md`.
class MapAppartement {
  int? id;
  String? title;
  String? reference;

  // Coordonnées obfusquées pour l'affichage sur la carte
  double? displayLat;
  double? displayLongi;

  // Coordonnées réelles (post-réservation uniquement, jamais en /filtered)
  double? realLat;
  double? realLongi;

  // Métadonnées pour le marker + bottom sheet preview
  int? price;
  String? typeAppart;
  int? nbChambres;
  String? imgUrl;

  // Adresse approximative (sans coordonnées exactes)
  String? communeName;
  String? addressDescription;

  MapAppartement({
    this.id,
    this.title,
    this.reference,
    this.displayLat,
    this.displayLongi,
    this.realLat,
    this.realLongi,
    this.price,
    this.typeAppart,
    this.nbChambres,
    this.imgUrl,
    this.communeName,
    this.addressDescription,
  });

  MapAppartement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'] ?? json['titre'];
    reference = json['reference'];
    displayLat = (json['displayLat'] ?? json['lat'])?.toDouble();
    displayLongi = (json['displayLongi'] ?? json['lng'])?.toDouble();
    realLat = json['realLat']?.toDouble();
    realLongi = json['realLongi']?.toDouble();
    final priceRaw = json['price'] ?? json['prix'];
    price = priceRaw is num ? priceRaw.toInt() : null;
    typeAppart = json['typeAppart'] ?? json['typeLocation'];
    nbChambres = json['nbChambres'];
    imgUrl = json['imgUrl'];
    communeName = json['communeName'];
    addressDescription = json['addressDescription'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'reference': reference,
      'displayLat': displayLat,
      'displayLongi': displayLongi,
      'realLat': realLat,
      'realLongi': realLongi,
      'price': price,
      'typeAppart': typeAppart,
      'nbChambres': nbChambres,
      'imgUrl': imgUrl,
      'communeName': communeName,
      'addressDescription': addressDescription,
    };
  }

  /// Position obfusquée pour les markers (toujours sûre).
  LatLng get displayPosition => LatLng(displayLat ?? 0, displayLongi ?? 0);

  /// Position réelle si chargée via `/real-location`. `null` en browse.
  LatLng? get realPosition => (realLat != null && realLongi != null)
      ? LatLng(realLat!, realLongi!)
      : null;

  bool get hasValidDisplayCoordinates =>
      displayLat != null && displayLongi != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapAppartement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MapAppartement{id: $id, title: $title, displayLat: $displayLat, '
        'displayLongi: $displayLongi, price: $price}';
  }
}
