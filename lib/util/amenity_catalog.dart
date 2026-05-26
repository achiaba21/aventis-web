/// Catalogue local des 16 chips de commodités proposées dans le wizard
/// d'annonce (step 4). Mapping figé `label UI → value backend`.
///
/// Aligné sur le brief mobile « Refonte commodités » (2026-05-16) :
/// - Les `value` correspondent à ce qui est seedé côté backend
/// - Le proprio choisit par label, on envoie l'`Offre(commodite)` avec
///   `value` renseignée → backend `findByValue` retrouve l'id existant
/// - `Commodite.getIcon()` mappe `value → IconData` pour l'affichage
///
/// L'`id` n'est pas figé ici — il vient du référentiel backend chargé via
/// `CommoditeCubit`. Le mapping label↔value reste local pour éviter une
/// dépendance dure au cubit dans l'UI quand le réseau échoue.
class AmenityCatalogEntry {
  final String label;
  final String value;
  final AmenitySection section;

  const AmenityCatalogEntry({
    required this.label,
    required this.value,
    required this.section,
  });
}

enum AmenitySection { essentiels, confort }

class AmenityCatalog {
  AmenityCatalog._();

  /// Référentiel local complet (16 entries). Source de vérité pour le wizard
  /// quand le référentiel backend n'est pas encore chargé.
  static const List<AmenityCatalogEntry> all = [
    // Section Essentiels
    AmenityCatalogEntry(
        label: 'WiFi', value: 'wifi', section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'WiFi fibre',
        value: 'wifi_fibre',
        section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'Clim', value: 'ac', section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'Eau chaude',
        value: 'hot_water',
        section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'Cuisine équipée',
        value: 'kitchen_eq',
        section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'Lave-linge',
        value: 'washing_machine',
        section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'Frigo',
        value: 'fridge',
        section: AmenitySection.essentiels),
    AmenityCatalogEntry(
        label: 'TV', value: 'tv', section: AmenitySection.essentiels),
    // Section Confort
    AmenityCatalogEntry(
        label: 'Parking',
        value: 'carpark',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Sécurité 24/7',
        value: 'security',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Piscine', value: 'pool', section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Salle de sport',
        value: 'gym',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Ascenseur',
        value: 'elevator',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Vue mer',
        value: 'sea_view',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Vue lagune',
        value: 'lagoon_view',
        section: AmenitySection.confort),
    AmenityCatalogEntry(
        label: 'Balcon',
        value: 'balcony',
        section: AmenitySection.confort),
  ];

  /// Filtré par section.
  static List<AmenityCatalogEntry> bySection(AmenitySection s) =>
      all.where((e) => e.section == s).toList();

  /// Trouve une entrée par son label UI. Retourne `null` si inconnu.
  static AmenityCatalogEntry? findByLabel(String label) {
    for (final e in all) {
      if (e.label == label) return e;
    }
    return null;
  }

  /// Trouve une entrée par sa `value` backend. Retourne `null` si inconnu.
  static AmenityCatalogEntry? findByValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final e in all) {
      if (e.value == value) return e;
    }
    return null;
  }
}
