# Design UI Validé — Carte Interactive Démarcheur

**Option choisie :** A — Parité locataire (navigation directe)
**Date validation :** 2026-05-28

---

## Placement

L'intégration se fait dans `DemarcheurListingsScreen`, branche `_showMap == true`. Le widget `ListingMapPane` (nouveau) remplace `ListingMapView` (à supprimer) et occupe la zone `Expanded` sous l'AppBar.

```
AppBar : [<] Choisir un logement     [list] [filtre]
─────────────────────────────────────────────────────
          ┌──────────────────────────┐
          │ 🔍 Rechercher un lieu... │  ← MapSearchBar (overlay top)
          └──────────────────────────┘

     [50k]                  [75k]
              [🍯]  ◄ marker central Yango (fixe)
        [42k]      [60k]                ← pins prix logements


  ┌─────────────────────┐  ┌─────┐
  │ 12 logements à      │  │ 📍 │       ← FAB MyLocation (right: 18, bottom: 24)
  │ Cocody Riviera      │  └─────┘
  └─────────────────────┘                ← MapZoneBanner (left: 18, right: 80)
─────────────────────────────────────────────────────
(pas de bouton Continuer sticky en mode carte)
```

## Décisions UI/UX

| Aspect | Décision |
|---|---|
| **Tap pin** | Navigation **directe** vers `DemarcheurAppartDetailScreen` (pas de bottom sheet, pas de sélection 2 temps) |
| **Bouton Continuer sticky** | **Masqué** en mode carte (s'affiche uniquement en vue liste) |
| **FAB MyLocation** | **Présent**, même position et comportement que locataire (right: 18, bottom: 24) |
| **Bandeau zone** | Wording neutre **« X logements à [zone] »** — wording actuel du `MapZoneBanner` réutilisé tel quel |
| **AppBar** | Conserve toggle carte/liste + bouton Filtrer badgé (cohérence avec liste) |
| **Search bar** | `MapSearchBar` standard via `InteractiveMapPicker` |
| **Overlays état** | Loading/Error/Empty via les 3 overlays mutualisés |

## Composants à Créer

- `ListingMapPane` (`lib/screen/client/demarcheur/listings/widget/listing_map_pane.dart`)
  - Compose `InteractiveMapPicker` + `MyLocationFab` + 3 overlays + listener BLoC
  - Pas de bottom sheet (tap pin → navigation directe via callback parent)

## Composants à Réutiliser (tels quels)

- `InteractiveMapPicker` (`lib/widget/map/interactive_map_picker.dart`) — inclut search bar + bandeau zone + marker central
- `MapSearchBar` (`lib/widget/map/map_search_bar.dart`)
- `MapZoneBanner` (`lib/widget/map/map_zone_banner.dart`) — wording neutre déjà OK
- `MapView`, `MapPricePin`, `MapPinMarker`
- `MyLocationFab` (`lib/screen/client/locataire/map/widget/my_location_fab.dart`) — à déplacer aussi ? Décision : laisser en place pour ne pas multiplier les déplacements, le démarcheur importe depuis ce chemin
- 3 overlays déplacés vers `lib/widget/map/overlay/` :
  - `MapLoadingOverlay`
  - `MapErrorOverlay`
  - `MapEmptyOverlay`

## Comportement bouton Continuer

Le bouton `_ContinueButton` sticky bas reste actif **en vue liste uniquement**. En vue carte (`_showMap == true`), le condition d'affichage est étendue : `if (_selectedId != null && !_showMap)`.

Justification : la navigation se fait directement depuis le tap pin, donc le bouton Continuer devient redondant en mode carte. Évite aussi d'occulter le bandeau zone.

## Contraintes Visuelles

- Respecter `AppColors.accent` (orange) pour les pins et le marker central
- Respecter `AppColors.background` pour le fond Scaffold
- Tuiles OSM dark identiques au locataire (`MapView` interne)
- Pas de duplication de style — tout via `map_config.dart`
- Animations debounce 300ms (déjà géré par `InteractiveMapPicker`)
- Padding/spacing : 18px latéraux (cohérent avec liste démarcheur)

## Comportement géolocalisation (FAB)

Identique au locataire :
- Tap FAB → `LocationUtil.getCurrentLatLng()` → `_mapCtrl.move(latLng, _userZoom)` + `LoadDemarcheurMapAppartements(latLng)`
- Si géoloc refusée → SnackBar d'invitation à activer dans les paramètres
- Pendant chargement : FAB en mode loading (spinner)
