import 'package:asfar/model/residence/appart.dart';

/// Couche d'adaptation entre le modèle Flutter et le backend.
///
/// Depuis le refactoring backend du 2026-05-13 (suppression de l'entité
/// `Residence` côté serveur), le payload est désormais **flat** : on envoie
/// `appartement.address` directement, sans embarquer une "shape résidence"
/// virtuelle.
///
/// Le seul ajustement subsistant est le retrait de `geoLat/geoLongi` au
/// `toCreatePayload` — le backend calcule ces coords automatiquement via
/// geocoding à la création (cf. brief 2026-05-13 + BACKEND_NOTES_MAP_V9_7B).
class AppartementBackendMapper {
  static AppartementBackendMapper? _instance;

  /// Singleton instance.
  static AppartementBackendMapper get instance {
    _instance ??= AppartementBackendMapper._internal();
    return _instance!;
  }

  AppartementBackendMapper._internal();

  /// Payload de création.
  ///
  /// Le backend calcule `geoLat/geoLongi` automatiquement à partir de
  /// `lat/longi` envoyés — on retire donc ces champs du payload sortant.
  Map<String, dynamic> toCreatePayload(Appartement appart) {
    final payload = appart.toJson();
    _stripGeoCalculatedFields(payload);
    return payload;
  }

  /// Payload de mise à jour. Identique à `toCreatePayload` côté shape.
  ///
  /// `backendResidenceId` conservé en paramètre pour rétro-compat des callers
  /// du repository, mais n'a plus d'effet — le backend n'utilise plus la
  /// table Residence.
  Map<String, dynamic> toUpdatePayload(
    Appartement appart, {
    int? backendResidenceId,
  }) {
    final _ = backendResidenceId;
    final payload = appart.toJson();
    _stripGeoCalculatedFields(payload);
    return payload;
  }

  /// Réception du DTO backend. Plus d'extraction `residence.address` — le
  /// modèle plat est désormais natif côté backend.
  Appartement fromBackendDto(Map<String, dynamic> json) {
    return Appartement.fromJson(json);
  }

  /// L'extraction de l'`id` de résidence n'a plus de sens — retourne `null`
  /// systématiquement pour les nouveaux DTOs. Conservé pour compat des
  /// tests legacy qui passent des fixtures avec une `residence` mockée.
  @Deprecated('Residence supprimée côté backend depuis 2026-05-13')
  int? extractBackendResidenceId(Map<String, dynamic> json) {
    final res = json['residence'];
    if (res is Map && res['id'] is int) return res['id'] as int;
    final flatId = json['residenceId'];
    return flatId is int ? flatId : null;
  }

  void _stripGeoCalculatedFields(Map<String, dynamic> payload) {
    final address = payload['address'];
    if (address is Map) {
      address.remove('geoLat');
      address.remove('geoLongi');
    }
  }
}
