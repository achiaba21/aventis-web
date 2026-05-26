# Architecture — `demarcheur-listing-filters`

**Date :** 2026-05-24

## Fichiers

### CRÉER
- `lib/screen/client/demarcheur/listings/listing_filters.dart`
  - Classe `ListingFilters` immutable : `typeLocations`, `proprietaireId`, `communeNom`, `isEmpty`, `activeCount`, `apply()`
- `lib/screen/client/demarcheur/listings/widget/listing_filter_bottom_sheet.dart`
  - `static Future<ListingFilters?> show(...)` — 3 sections dynamiques + Appliquer/Réinitialiser
- `lib/screen/client/demarcheur/listings/widget/listing_map_view.dart`
  - Vue carte avec FlutterMap, masquée `if (false)`, mapper `Appartement→MapAppartement` inline

### MODIFIER
- `lib/model/residence/appart.dart`
  - + `double? lat`, `double? lon` (déclaration, constructeur, fromJson, copyWith, toJson)
- `lib/screen/client/demarcheur/listings/demarcheur_listings_screen.dart`
  - + `_activeFilters`, `_openFilters()`, `_FilterButton` privé avec badge
  - + filtrage AND client-side
  - + toggle carte dans `if (false)`

## Flux de données

```
BlocBuilder(DemarcheurDataLoaded)
  → _sorted(state.appartements) = allApparts
  → _activeFilters.apply(allApparts) = apparts (filtrés)
  → apparts.isEmpty && !_activeFilters.isEmpty → EmptyState.inline + CTA reset
  → else → ListView (existant)
  → if (false) → ListingMapView (câblé, jamais rendu)
```

## Décisions
- Pas de nouveau BLoC — filtres éphémères dans le State
- `_openFilters()` lit le BLoC au moment du tap (pas de champ `_allApparts` supplémentaire)
- Badge : 1 point par **section** active (max 3), pas par valeur
- `ListingMapView` : mapper `Appartement→MapAppartement` inline (helper privé)
- Sections de la bottom sheet masquées si < 2 valeurs uniques dans le dataset

## Contrat d'implémentation

### Modèle
- [ ] `Appartement` + `double? lat`, `double? lon` (déclaration, constructeur, fromJson, copyWith, toJson)

### `listing_filters.dart`
- [ ] `ListingFilters` const constructor immutable
- [ ] `typeLocations: Set<AppartementTypeLocation>` multi-select (vide = inactif)
- [ ] `proprietaireId: int?` single-select
- [ ] `communeNom: String?` single-select
- [ ] `bool get isEmpty`
- [ ] `int get activeCount` (1 par section active)
- [ ] `List<Appartement> apply(List<Appartement>)` AND + OR intra-Pièces + null guards
- [ ] `ListingFilters copyWith(...)` avec sentinel pour nullable reset

### `listing_filter_bottom_sheet.dart`
- [ ] `static Future<ListingFilters?> show(BuildContext, {allApparts, current})`
- [ ] State `_draft` local initialisé depuis `current`
- [ ] Section Pièces masquée si < 2 types présents dans le dataset
- [ ] Section Partenaire masquée si < 2 propriétaires uniques
- [ ] Section Zone masquée si < 2 communes uniques
- [ ] Chips Pièces multi-select (toggle Set)
- [ ] Chips Partenaire single-select (toggle)
- [ ] Chips Zone single-select (toggle)
- [ ] "Réinitialiser" → `_draft = const ListingFilters()`
- [ ] "Appliquer" → `Navigator.pop(context, _draft)`
- [ ] `isScrollControlled: true`, max 80% viewport, bgElev1, borderRadius top 24
- [ ] Drag handle + SafeArea bottom

### `listing_map_view.dart`
- [ ] `List<Appartement> appartements`, `int? selectedId`, `void Function(Appartement) onTap`
- [ ] Helper `_toMapAppartement(Appartement)` inline
- [ ] Filtre `.where((a) => a.lat != null && a.lon != null)` avant markers
- [ ] Réutilise `MapView` (locataire)
- [ ] Centre Abidjan fallback `LatLng(5.345, -4.024)`

### `demarcheur_listings_screen.dart`
- [ ] `ListingFilters _activeFilters = const ListingFilters()`
- [ ] `bool _showMap = false` (non utilisé — prêt)
- [ ] `_openFilters()` : lit BLoC au tap, `await ListingFilterBottomSheet.show`
- [ ] AppBar : `trailing: _FilterButton(activeCount, onPressed: _openFilters)`
- [ ] `allApparts` → `_activeFilters.apply()` → `apparts`
- [ ] EmptyState.inline si `apparts.isEmpty && !_activeFilters.isEmpty`
- [ ] `if (false)` bloc toggle carte + `ListingMapView` commenté
- [ ] `_FilterButton` : Stack + IconBoutton(tune) + badge conditionnel (accent 16×16)

UI_REQUIRED: true
