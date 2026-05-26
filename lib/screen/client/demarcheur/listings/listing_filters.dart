import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/residence/appart.dart';

/// Critères de filtre pour l'écran "Choisir un logement".
///
/// Immuable — chaque modification produit une nouvelle instance via [copyWith].
/// Filtrage AND : seuls les logements vérifiant tous les critères actifs
/// sont retenus. Au sein de [typeLocations], la logique est OR (multi-select).
class ListingFilters {
  final Set<AppartementTypeLocation> typeLocations;
  final int? proprietaireId;
  final String? communeNom;

  const ListingFilters({
    this.typeLocations = const {},
    this.proprietaireId,
    this.communeNom,
  });

  bool get isEmpty =>
      typeLocations.isEmpty && proprietaireId == null && communeNom == null;

  /// Nombre de sections actives (max 3) — utilisé pour le badge du bouton filtre.
  int get activeCount {
    int c = 0;
    if (typeLocations.isNotEmpty) c++;
    if (proprietaireId != null) c++;
    if (communeNom != null) c++;
    return c;
  }

  /// Applique les filtres actifs à [source] et retourne la liste filtrée.
  List<Appartement> apply(List<Appartement> source) {
    return source.where((a) {
      if (typeLocations.isNotEmpty) {
        if (a.typeLocation == null) return false;
        if (!typeLocations.contains(a.typeLocation)) return false;
      }
      if (proprietaireId != null) {
        if (a.proprietaire?.id != proprietaireId) return false;
      }
      if (communeNom != null) {
        if (a.communeNom != communeNom) return false;
      }
      return true;
    }).toList();
  }

  ListingFilters copyWith({
    Set<AppartementTypeLocation>? typeLocations,
    Object? proprietaireId = _sentinel,
    Object? communeNom = _sentinel,
  }) {
    return ListingFilters(
      typeLocations: typeLocations ?? this.typeLocations,
      proprietaireId: proprietaireId == _sentinel
          ? this.proprietaireId
          : proprietaireId as int?,
      communeNom:
          communeNom == _sentinel ? this.communeNom : communeNom as String?,
    );
  }
}

const _sentinel = Object();
