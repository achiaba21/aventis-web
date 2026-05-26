# 🎨 Design UI Validé — `interactive-map-picker`

**Date :** 2026-05-26
**Options choisies :** Zone 1 → B · Zone 2 → B · Zone 3 → A

---

## Layout global validé

```
┌────────────────────────────────────────┐
│  ←        Carte             ⚙          │  ← AppBar (existante)
├────────────────────────────────────────┤
│ ┌────────────────────────────────────┐ │
│ │ 🔍 Rechercher un quartier...       │ │  ← Zone 1B : MapSearchBar flottante
│ └────────────────────────────────────┘ │
│                                        │
│           [carte dark OSM]             │
│                                        │
│                📍                      │  ← Zone 2B : MapPinMarker + ombre
│                ●                       │     (overlay Align.center)
│                                        │
│                                        │
│  ╭──────────────────────────╮          │  ← Zone 3A : MapZoneBanner pill
│  │ 23 résidences à Cocody   │  [⦿]    │     (pill bgElev2 + shadow)
│  ╰──────────────────────────╯          │
└────────────────────────────────────────┘
```

---

## Zone 1 — Search bar flottante sous AppBar (option B)

### Placement
- **Position :** `Positioned(top: 12, left: 16, right: 16)` dans le Stack
- **Au-dessus de :** MapView (z-index supérieur)
- **Coexiste avec :** AppBar (titre "Carte" + bouton tune trailing conservés)

### Specs visuelles
- Container :
  - Fond : `AppColors.bgElev1`
  - Border : `AppColors.line`, 1px
  - Radius : `AppRadii.lg` (12px)
  - Shadow : `BoxShadow(blurRadius: 12, offset: Offset(0, 4), color: Color(0x66000000))`
  - Padding : `EdgeInsets.symmetric(horizontal: 14, vertical: 12)`
- TextField interne :
  - Hint : "Rechercher un quartier, une adresse…" (text3 italic)
  - Style texte : `AppTextStyles.body` (15px, text)
  - Icône leading : `Icons.search` 20px, `AppColors.text2`
  - Icône trailing :
    - Si `loading == false` : pas d'icône (submit clavier ou icône loupe leading clickable)
    - Si `loading == true` : `CircularProgressIndicator` 16×16 stroke 2 accent
    - Si error != null : `Icons.error_outline` 20px danger + texte erreur INLINE sous le field (rouge `AppColors.danger`, 11px, padding-top 4)

### États
- **Normal** : container bgElev1 + border line
- **Focus** : border accent or 1.5px, shadow plus prononcée
- **Loading** : spinner trailing
- **Erreur** : message rouge inline sous le field

---

## Zone 2 — MapPinMarker + ombre projetée (option B)

### Placement
- **Position :** `Align(alignment: Alignment.center)` dans le Stack au-dessus de MapView
- **Le marker NE bouge PAS quand la carte drag** — il est ancré au centre visuel du viewport
- Coexiste avec les MapPricePin déjà rendus DANS le MapView (markers de résidences)

### Specs visuelles
- Réutilise `MapPinMarker` (existant `lib/widget/map/map_pin_marker.dart`) :
  - Pin accent or 44px par défaut, halo subtil autour
- **Ombre projetée additionnelle** (ajoutée dans `InteractiveMapPicker` au niveau wrapper) :
  - Container Stack wrapper qui inclut le pin + une petite ellipse plus basse
  - Ellipse : 16×6, fond `Color(0x55000000)` (noir 33% opacity), blur 6px
  - Offset vertical : ~6px sous la pointe du pin
  - Effet : "le pin flotte au-dessus de la carte"
- Pendant fling/drag : pas d'animation supplémentaire (KISS — pas de scale)

### Comportement
- Toujours visible (pas de masquage pendant drag)
- Toujours centré dans le viewport (overlay Stack)
- Lit la position au centre via `_mapCtrl.camera.center` au `MapEventMoveEnd`

---

## Zone 3 — Pill bottom-center discret (option A)

### Placement
- **Position :** `Positioned(bottom: 24 + safeArea, left: 18, right: 80)` — laisse la place au FAB MyLocation à droite
- **Au-dessus de :** MapView et MapPinMarker
- Coexiste avec :
  - `MyLocationFab` à `right: 18, bottom: 24` (existant — non bougé)
  - Overlays loading/error/empty qui peuvent s'afficher par-dessus (état exceptionnel)

### Specs visuelles
- Container pill :
  - Fond : `AppColors.bgElev2`
  - Border : `AppColors.line`, 1px
  - Radius : `AppRadii.pill`
  - Shadow : `BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x66000000))`
  - Padding : `EdgeInsets.symmetric(horizontal: 14, vertical: 8)`
  - `mainAxisSize: MainAxisSize.min` pour s'adapter au contenu
- Texte :
  - Style : `AppTextStyles.body` (13px, w500, text)
  - Formats :
    - **N > 0 avec zoneName** : "23 résidences à Cocody Riviera"
    - **N > 0 sans zoneName** : "23 résidences dans cette zone"
    - **N == 0 avec zoneName** : "Aucune résidence à Cocody Riviera" (text2)
    - **N == 0 sans zoneName** : "Aucune résidence dans cette zone" (text2)
- Si `isLoading == true` : remplacer par shimmer pill de la même taille (cohérence visuelle pendant les transitions)
- `AnimatedSwitcher` : `duration: 200ms`, `transitionBuilder: FadeTransition` pour transitions fluides entre updates

---

## Composants à créer

| Widget | Fichier | Réutilise |
|---|---|---|
| `InteractiveMapPicker` | `lib/widget/map/interactive_map_picker.dart` | `MapView`, `MapPinMarker`, `MapSearchBar`, `MapZoneBanner` |
| `MapSearchBar` | `lib/widget/map/map_search_bar.dart` | `AppColors`, `AppRadii`, `AppTextStyles` |
| `MapZoneBanner` | `lib/widget/map/map_zone_banner.dart` | `AppColors`, `AppRadii`, `AppTextStyles` |

## Composants à réutiliser

| Widget | Source |
|---|---|
| `MapView` | `lib/widget/map/map_view.dart` |
| `MapPinMarker` | `lib/widget/map/map_pin_marker.dart` |
| `MapPricePin` | `lib/widget/map/map_price_pin.dart` (déjà utilisé par MapView) |
| `MyLocationFab` | `lib/screen/client/locataire/map/widget/my_location_fab.dart` |
| `MapLoadingOverlay`, `MapErrorOverlay`, `MapEmptyOverlay` | `lib/screen/client/locataire/map/widget/` |

## Contraintes visuelles

- **Pas de masquage plein écran** : tous les overlays nouveaux (search, banner) laissent voir la carte
- **Palette stricte** : aucune nouvelle couleur — uniquement les tokens `AppColors`
- **Tokens texte** : `AppTextStyles.body` partout sauf erreur inline (rouge danger 11px)
- **Shadow réutilisée** : `Color(0x66000000)` pour search bar, `Color(0x66000000)` lighter pour banner — cohérence avec MapPricePin existant
- **Safe area** : la position bottom du banner et FAB respecte `mediaQuery.padding.bottom`
- **Accessibilité** : taille des cibles tactiles ≥ 44×44 (search trailing icon, FAB déjà OK)

## Hors-scope UI V1 (cf. architecture §8)
- Pas d'animation de scale du pin pendant drag
- Pas d'autocomplete dans la search bar (juste submit + erreur inline)
- Pas d'icône zone dans le banner (l'option B "card pleine largeur" l'aurait inclus, on a choisi A plus discret)
