# 🎨 Design UI Validé — V9.7 Carte Interactive

**Option choisie pour les tuiles : ColorFiltered sur OSM**

## Approche tuiles

Tuiles OSM standard (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`)
wrappées dans un `ColorFiltered` avec matrice `ColorFilter.matrix`
appliquant invert luminance + désaturation légère. Résultat : carte
"dark mode" cohérente avec Asfar Premium sans clé API ni dépendance
externe.

```dart
// Matrice de transformation : invert + désature légèrement
const _darkenMatrix = <double>[
  -0.85, -0.10, -0.10, 0, 255,
  -0.10, -0.85, -0.10, 0, 255,
  -0.10, -0.10, -0.85, 0, 255,
       0,    0,    0, 1,   0,
];
```

Justification : zéro coût, zéro dépendance, markers accent or ressortent
sur fond sombre, attribution OSM préservée.

---

## Spécifications visuelles par composant

### 1. MapPriceMarker (pill prix)

**Dimensions :** ~52×26 px, padding horizontal 10, padding vertical 4

**Couleurs :**
- Background : `AppColors.accent` (#E8B86B)
- Texte : `AppColors.onAccent` (#1A1206)
- Border : aucune
- Shadow : `BoxShadow(blurRadius: 4, color: black.withOpacity(0.25))`

**Forme :** `BorderRadius.circular(99)` pill complète

**Texte :** prix compact via `FcfaFormatter.compact` → `'45k'`, `'1.2M'`,
fontSize 12, FontWeight.w700, mono via `AppTextStyles.mono`

**État actif** (futur — marker sélectionné) : background `accent` →
border `2px onAccent` + shadow plus prononcée. Hors scope V9.7
(markers individuels sans selection state pour MVP).

**Pas de pointer/triangle bottom** — style moderne flat.

---

### 2. MapMarkerBottomSheet (preview au tap)

**Hauteur :** ~300 px (auto selon contenu)

**Structure :**
```
┌─────────────────────────────────┐
│         ───── (handle)          │  ← 4×40 bgElev3 radius 99
│                                 │
│ ┌─────────────────────────────┐ │
│ │     image 16:9 (ImgPh)      │ │  ← placeholder Asfar tone
│ │                             │ │
│ └─────────────────────────────┘ │
│                                 │
│ Loft Plateau (h3 white)         │  ← AppTextStyles.h3, 18px w600
│ 35 000 - 45 000 FCFA · Plateau  │  ← AppTextStyles.small, text2
│ 3 appartements                  │  ← AppTextStyles.small, fontSize 12
│                                 │
│ ┌─────────────────────────────┐ │
│ │      Voir détails (lg)      │ │  ← CustomButton primary lg block
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

**Tokens :**
- Background : `AppColors.bgElev1` (#131316)
- Padding : `EdgeInsets.fromLTRB(18, 8, 18, 24)`
- Top corners radius : 24 px (signature bottom sheet Asfar)
- Handle bar : `Container(width: 40, height: 4, color: bgElev3, radius: 99)` centré
- Image : `ImgPh(tone: tone, radius: 14)` avec tone calculé `(residence.id % 4) + 1`
- Bouton : `CustomButton(text: 'Voir détails', size: ButtonSize.lg, block: true)`

**Composition de la sub-info :** `'${priceRange} · ${communeName} · X appartement${X>1?'s':''}'`
avec fallback si null

**Animation :** modal Flutter natif (`showModalBottomSheet`) avec
`isScrollControlled: false`, `useSafeArea: true`.

---

### 3. MyLocationFab (FAB position)

**Dimensions :** 56×56 (taille FAB Material standard)

**Position :** `Positioned(right: 18, bottom: 100)` — au-dessus du
BottomNav (qui fait ~78px de hauteur)

**Style :**
- Background : `AppColors.accent` (#E8B86B)
- Icon : `Icons.my_location`, size 24, color `AppColors.onAccent`
- Shadow : `BoxShadow(blurRadius: 12, offset: Offset(0, 4), color: black.withOpacity(0.4))`
- Border : aucune
- Radius : `BorderRadius.circular(28)` cercle parfait

**État de chargement** (pendant getCurrentPosition) : icon → `CircularProgressIndicator(color: onAccent, strokeWidth: 2)`

---

### 4. SearchInAreaButton (chip "Rechercher dans cette zone")

**Position :** `Positioned(top: 12, left: 0, right: 0)` avec
`Align(alignment: Alignment.topCenter)` — centré horizontalement
sous l'app bar.

**Animation apparition/disparition :** `AnimatedOpacity(duration: 200ms,
opacity: visible ? 1.0 : 0.0)` + `IgnorePointer(ignoring: !visible)`.

**Style :**
- Background : `AppColors.bgElev1` opacity 0.95 (semi-transparent pour
  laisser deviner la carte derrière)
- Border : `1px AppColors.line`
- Padding : `EdgeInsets.symmetric(horizontal: 16, vertical: 10)`
- Radius : `BorderRadius.circular(99)` pill
- Shadow : `BoxShadow(blurRadius: 8, color: black.withOpacity(0.3))`
- Contenu : Row(min) = `Icon(Icons.refresh, size: 16, color: accent)`
  + SizedBox(8) + `Text('Rechercher dans cette zone',
  style: AppTextStyles.small.copyWith(fontWeight: w600, color: text))`

---

### 5. MapLoadingOverlay (loading non-bloquant)

**Position :** centré dans la carte via `Center`

**Style :**
- Container 80×80 padding 16
- Background : `AppColors.bgElev1` opacity 0.95
- Border : `1px AppColors.line`
- Radius : `AppRadii.lg` (20)
- Shadow : `BoxShadow(blurRadius: 12, color: black.withOpacity(0.4))`
- Contenu : Column(min) = `CircularProgressIndicator(color: accent, strokeWidth: 2.5)` size 24 + SizedBox(8) + `Text('Chargement…', style: AppTextStyles.small)`

**Pas bloquant :** la carte reste visible et interactive en dessous.

---

### 6. MapEmptyOverlay (aucun listing en zone)

**Position :** centré, padding latéral 24

**Style :**
- Réutilise `EmptyState.inline` avec :
  - `icon: Icons.location_off_outlined`
  - `title: 'Aucun logement dans cette zone'`
  - `body: 'Élargissez la zone de recherche ou changez les filtres.'`
  - `ctaLabel: 'Élargir la zone'` (optionnel)
  - `onCtaTap: onExpandRadius`
- Wrappé dans `Container(decoration: bgElev1+line+lg, padding: 18)`
  pour visibilité sur la carte

---

### 7. MapErrorOverlay (erreur réseau)

**Position :** centré

**Style :**
- Réutilise `EmptyState.error` avec :
  - `message: error.message`
  - `onRetry: onRetry`
- Wrappé dans `Container(decoration: bgElev1+line+lg, padding: 18)`

---

## Composants à réutiliser

- `EmptyState.inline` (Lot 1 V8.5) — pour empty + error overlays
- `CustomButton` — bouton "Voir détails"
- `ImgPh` — image placeholder bottom sheet
- `IconBoutton` — back button app bar
- `DynamicAppBar` — app bar avec titre "Carte" + trailing "Filtrer"
- `FcfaFormatter.compact` — labels markers
- `AppTextStyles.h3/small/mono/eyebrow` — typographie
- `AppRadii.lg/md/sm` — radii cohérents
- `AppColors.*` tokens — palette uniquement

---

## Layout général LocataireMapScreen

```
┌─────────────────────────────────────┐
│ ← Carte         Filtrer ☰  (appBar) │ ← DynamicAppBar
├─────────────────────────────────────┤
│      ┌──────────────────────┐       │
│      │ ↻ Rechercher ici     │       │ ← SearchInAreaButton (animated)
│      └──────────────────────┘       │
│                                     │
│   [45k]                             │
│              [32k]                  │
│                                     │  ← FlutterMap dark filtered
│       [68k]                         │
│                  [Loading…]         │ ← MapLoadingOverlay
│                                     │
│   [55k]                             │
│                                     │
│                              ┌───┐  │
│                              │ ⊙ │  │ ← MyLocationFab
│                              └───┘  │
└─────────────────────────────────────┘
```

---

## Contraintes visuelles respectées

- **Palette** : 100% tokens `AppColors.*` (zéro hex ad-hoc dans le code,
  sauf la matrice ColorFilter qui est utilitaire)
- **Typographie** : `AppTextStyles.*` exclusivement
- **Radii** : `AppRadii.lg/md/sm` + `99` pour pills + `24` pour bottom
  sheet (signature)
- **Cohérence** : tous les overlays utilisent `bgElev1 + line + radius lg`
- **Animations** : 200ms ease pour fade (chip search), default Flutter
  pour bottom sheet
- **Accessibilité** : contrastes onAccent/accent > 7:1 (WCAG AAA),
  text/bgElev1 > 7:1, tap zones >= 44×44 (FAB 56, marker 52×26 → bordure
  tap étendue à 48 avec InkWell zone)
- **60 FPS** : pas d'animation lourde, ColorFiltered est GPU-accelerated
- **Règle Flutter n°1** : chaque widget = fichier dédié, zéro `_buildXxx`
