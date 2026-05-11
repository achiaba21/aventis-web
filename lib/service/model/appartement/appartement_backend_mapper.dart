import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/appart.dart';

/// Couche d'adaptation TEMPORAIRE entre le modèle plat de l'app et le backend
/// Spring Boot qui attend encore une "residence" englobante.
///
/// IMPORTANT : ce fichier est le SEUL endroit autorisé à manipuler la
/// "shape résidence" attendue par le backend. Aucune classe Dart `Residence`
/// n'est importée — uniquement des `Map<String, dynamic>`.
///
/// TODO BACKEND-FLAT-APPART
/// Quand le backend acceptera `appartement.address` directement,
/// supprimer toutes les méthodes `_buildLegacyResidenceShape` et
/// `_extractAddressFromLegacy`, et simplifier `toCreatePayload`/`toUpdatePayload`
/// à un simple `appart.toJson()` (qui contient déjà `address`).
class AppartementBackendMapper {
  static AppartementBackendMapper? _instance;

  /// Singleton instance.
  static AppartementBackendMapper get instance {
    _instance ??= AppartementBackendMapper._internal();
    return _instance!;
  }

  AppartementBackendMapper._internal();

  /// À l'envoi (création) : produit le payload backend en embarquant
  /// une "shape résidence" autour de l'address.
  Map<String, dynamic> toCreatePayload(Appartement appart) {
    final payload = appart.toJson();
    payload.remove('address'); // backend ne connaît pas encore ce champ
    payload['residence'] = _buildLegacyResidenceShape(appart, withId: false);
    return payload;
  }

  /// À l'envoi (update) : préserve l'ID de la résidence existante côté backend
  /// (transmis explicitement par le repository qui le maintient en cache mémoire).
  Map<String, dynamic> toUpdatePayload(
    Appartement appart, {
    int? backendResidenceId,
  }) {
    final payload = appart.toJson();
    payload.remove('address');
    payload['residence'] = _buildLegacyResidenceShape(
      appart,
      withId: true,
      existingId: backendResidenceId,
    );
    if (backendResidenceId != null) {
      payload['residenceId'] = backendResidenceId;
    }
    return payload;
  }

  /// À la réception : fusionne `json['residence']['address']` dans
  /// `appart.address`. L'objet retourné n'a aucune trace de Residence.
  Appartement fromBackendDto(Map<String, dynamic> json) {
    final addressMap = _extractAddressFromLegacy(json);
    final cleaned = Map<String, dynamic>.from(json)
      ..remove('residence')
      ..remove('residenceId');
    final appart = Appartement.fromJson(cleaned);
    if (appart.address == null && addressMap != null) {
      appart.address = Address.fromJson(addressMap);
    }
    return appart;
  }

  /// Extrait l'ID de la résidence backend depuis un DTO. Utile pour le
  /// repository qui maintient `Map<int appartId, int backendResidenceId>`.
  int? extractBackendResidenceId(Map<String, dynamic> json) {
    final res = json['residence'];
    if (res is Map && res['id'] is int) {
      return res['id'] as int;
    }
    final flatId = json['residenceId'];
    return flatId is int ? flatId : null;
  }

  // ============== Helpers privés (à supprimer le jour J) ==============

  Map<String, dynamic> _buildLegacyResidenceShape(
    Appartement appart, {
    required bool withId,
    int? existingId,
  }) {
    final shape = <String, dynamic>{
      'nom': _autoName(appart),
    };
    if (withId && existingId != null) {
      shape['id'] = existingId;
    }
    if (appart.address != null) {
      final addressMap = appart.address!.toJson();
      // V9.2 : le backend calcule `geoLat`/`geoLongi` automatiquement via
      // geocoding lors de la création — ne plus les envoyer côté Flutter
      // (cf. BACKEND_NOTES_MAP_V9_7B.md).
      addressMap.remove('geoLat');
      addressMap.remove('geoLongi');
      shape['address'] = addressMap;
    }
    return shape;
  }

  Map<String, dynamic>? _extractAddressFromLegacy(Map<String, dynamic> json) {
    final res = json['residence'];
    if (res is Map && res['address'] is Map) {
      return Map<String, dynamic>.from(
        (res['address'] as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }
    return null;
  }

  /// Nom auto-généré pour la résidence virtuelle.
  /// Reste lisible si on consulte la BDD : "Studio Cocody — Cocody" ou "Bien".
  String _autoName(Appartement appart) {
    final loc = appart.address?.commune?.nom ?? appart.address?.nom ?? 'Bien';
    final titre = appart.titre?.trim();
    if (titre != null && titre.isNotEmpty) {
      return '$titre — $loc';
    }
    return loc;
  }
}
