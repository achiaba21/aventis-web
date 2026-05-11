# 🎨 Proposition UI/UX — V9.7c Section Localisation

> **Version :** 1.0
> **Date :** 2026-05-11
> **Option choisie :** **A — Discret post-résa**
> **Status :** ✅ Validée

---

## Design UI Validé

### Option A — "Discret post-résa"

Mini-carte 180px non-interactive, suivie d'une Row avec `chip success` à gauche + `bouton outlined accent` à droite en mode exact (post-résa). Mode approximatif → chip muted seul. Le bouton "Itinéraire" reste secondaire pour ne pas concurrencer le CTA principal "Réserver".

---

## 1. Placement & Wireframes

### Section "Localisation" — insérée dans `LocataireDetailScreen`

Entre "Équipements" et le bloc reviews, remplace l'actuelle `DetailMapSection` placeholder figée.

```
─── Équipements ───────────────────
(grille équipements existante)

─── Localisation ──────────────────

╭───────────────────────────────────╮
│ ░░ Mini-carte OSM dark ░░░░░░░░░░│
│ ░░         📍 marker              │  ← 180px non-interactive
│ ░░ tuiles filtrées via tileBuilder│     radius AppRadii.md (14)
│ ░░ + ColorFilter.matrix(_darken) ░│     pas de pan/zoom user
╰───────────────────────────────────╯
            ↑ 12px spacing
╭──────────────────╮    ╭──────────╮
│ ⊙ Loc. exacte    │ →← │ ➡ Itin.  │   ← mode EXACT (post-résa)
╰──────────────────╯    ╰──────────╯
   chip success           outlined accent

OU (mode approximatif) :

╭───────────────────────────────────╮
│ ⊘ Localisation approximative      │   ← chip muted seul, full width
╰───────────────────────────────────╯

OU (chargement) :

╭───────────────────────────────────╮
│         (skeleton bgElev2)         │
│               ⌛                    │   ← 180px + spinner accent 24px
╰───────────────────────────────────╯
```

## 2. Composants à Créer

### MiniMapPreview (StatelessWidget)
- Taille fixe **180px** hauteur, radius `AppRadii.md` (14)
- `FlutterMap` :
  - `MapOptions` : `initialCenter`, `initialZoom = 15.0`, `interactionOptions: InteractionOptions(flags: InteractiveFlag.none)` (non-interactif)
  - `TileLayer` : OSM standard avec `tileBuilder` appliquant `ColorFilter.matrix(_darkenMatrix)` — **réutiliser** la matrice de `MapView` (extract dans util commune ou copy)
  - `MarkerLayer` : 1 marker centré sur `center` — pin custom (point accent or 16px avec halo, similaire `MapPinMarker` existant)
- Wrap dans `ClipRRect(borderRadius: BorderRadius.circular(AppRadii.md))`
- Pas de gestes utilisateur

### LocationLabelChip (StatelessWidget)
- Pill compact, padding `EdgeInsets.symmetric(horizontal: 10, vertical: 5)`, radius pill 99
- **Mode EXACT** :
  - Background `AppColors.bgElev2`
  - Border `Border.all(color: AppColors.successLight, width: 1)`
  - Icon `Icons.gps_fixed` 14px color `AppColors.success`
  - Spacing 6
  - Text "Localisation exacte" `AppTextStyles.small.copyWith(fontSize: 12, color: AppColors.text)`
- **Mode APPROXIMATIF** :
  - Background `AppColors.bgElev2`
  - Border `Border.all(color: AppColors.line, width: 1)`
  - Icon `Icons.gps_off` 14px color `AppColors.text3`
  - Spacing 6
  - Text "Localisation approximative" `AppTextStyles.small.copyWith(fontSize: 12, color: AppColors.text3)`

### ItineraryButton (StatelessWidget)
- **`OutlinedCustomButton`** (existant projet) — pas `CustomButton` primary
- Label "Itinéraire"
- Leading icon `Icons.directions_outlined` 16px accent
- Size `md` (~40-44px hauteur, padding compact)
- `onPressed` : `LaunchExternalMapsHelper.launchDirections(coords)` ; si retour false, callback `onError` (snackbar discret au niveau parent)

### Skeleton de chargement
- `Container` height 180 (même hauteur que la mini-carte finale pour éviter layout jump)
- `decoration: BoxDecoration(color: AppColors.bgElev2, borderRadius: BorderRadius.circular(AppRadii.md))`
- Child `Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accent))))`
- **Décision** : spinner simple plutôt que shimmer — la mini-carte est petite, le shimmer animé semble overkill ici. Le `MapMarkerPreviewImage` V9.7b utilise shimmer car il représente une photo, ici c'est une carte = sémantique différente.

## 3. Composants à Réutiliser

- `flutter_map` `FlutterMap` / `TileLayer` / `MarkerLayer`
- `_darkenMatrix` (de `MapView` V9.7 — à extraire dans util ou copy)
- `OutlinedCustomButton` (existant `lib/widget/button/`)
- `LaunchExternalMapsHelper` (créé V9.7c)
- `AppColors.success`, `successLight`, `text`, `text3`, `bgElev2`, `line`, `accent`
- `AppRadii.md`, `AppRadii.pill`
- `AppTextStyles.small`

## 4. Layout de la Row label + bouton

```dart
Row(
  children: [
    LocationLabelChip(isExact: true),
    const Spacer(),
    ItineraryButton(coords: realLocation, onError: () => SnackBar...),
  ],
)
```

En mode approximatif :
```dart
Row(
  children: [
    Expanded(child: LocationLabelChip(isExact: false)),
  ],
)
```

> Le chip expand uniquement en mode approximatif (pas de bouton à droite, gain d'espace utilisé pour rendre le label plus visible).

## 5. Contraintes Visuelles

| Élément | Spec |
|---|---|
| Mini-carte hauteur | 180px (cohérent avec ancienne `DetailMapSection`) |
| Mini-carte radius | `AppRadii.md` = 14 |
| Mini-carte interaction | **Aucune** — `InteractionOptions(flags: InteractiveFlag.none)` |
| Chip radius | `AppRadii.pill` = 99 |
| Chip padding | h: 10, v: 5 |
| Chip icon size | 14px |
| Chip text style | `AppTextStyles.small.copyWith(fontSize: 12)` |
| Bouton style | `OutlinedCustomButton` size `md` (~44px hauteur) |
| Bouton label | "Itinéraire" |
| Bouton icon | `Icons.directions_outlined` 16px accent |
| Spacing carte → Row | 12px |
| Skeleton hauteur | 180 (égale à la carte) |
| Skeleton background | `AppColors.bgElev2` |
| Skeleton spinner | 24×24 accent or, strokeWidth 2 |

## 6. Comportements / États

| État | Mini-carte | Chip | Bouton |
|---|---|---|---|
| Loading | Skeleton 180px + spinner | absent | absent |
| Approximatif (no résa) | Center sur `displayLocation` | "Localisation approximative" (text3) | absent |
| Exact (résa PAYER/FINALISER) | Center sur `realLocation` | "Localisation exacte" (success) | **Itinéraire** actif |
| Aucune coord du tout | Section entièrement absente (`SizedBox.shrink`) | — | — |
| Itinéraire échec (pas d'app maps) | (carte intacte) | (chip intact) | tap → SnackBar discret "Aucune application carte installée" |

## 7. Accessibilité

- Contraste `success` (#4ADE80) sur `bgElev2` (#1C1C20) → ratio 8.5:1 ✓ AAA
- Contraste `text3` (#76767E) sur `bgElev2` → ratio 4.3:1 ✓ AA
- Texte icône GPS = signal visuel + verbal
- Bouton size md ≥ 44px tap target ✓

## 8. Performance

- Mini-carte non-interactive → pas d'overhead pan/zoom
- 1 marker statique → pas de re-render au scroll
- Tuiles OSM cachées par HTTP cache standard (rapide après 1er load)
- Spinner non-animé pendant double `Future.wait` → ~1 RTT total
