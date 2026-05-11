# 🎨 Proposition UI/UX — V9.1 Wizard création appartement

> **Version :** 1.0
> **Date :** 2026-05-11
> **Options choisies :** A=chip corner / B=DashedBorderContainer / C=AsfarToggle custom
> **Status :** ✅ Validée

---

## Design UI Validé

### Réutilisations confirmées
- `BlurContainer` (existant) — wrap du `WizardCtaBar`
- `CustomButton` lg block (existant) — CTA "Continuer" / "Publier mon annonce"
- `OutlinedCustomButton` (existant) — bouton "Recommencer" dans `ResumeDraftDialog`
- `IconBoutton` (existant) — back de TopNav
- `ImgPh` (existant) — placeholder photo dans grille upload + fallback
- `MiniMapPreview` V9.7c — preview map GPS si capturé
- `DashedBorderContainer` (existant V7, CustomPainter) — bordure dashed `PhotosUploadCard`
- `AppColors` / `AppRadii` / `AppTextStyles` — palette/tokens
- `osmDarkMatrix` indirectement via `MiniMapPreview`
- `FcfaFormatter.full` — formatage prix dans `PricingCommissionPreview`

### Composants à créer (proto fidèle)

#### 1. WizardStepIndicator
```
┌─ ◄ ─── Nouvelle annonce ──────────── ─┐
│         Étape 2 / 5                    │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ ← progress bar 4px
└────────────────────────────────────────┘
```
- TopNav style projet : back IconBoutton + titre `AppTextStyles.h3` "Nouvelle annonce" + sub `AppTextStyles.small.copyWith(fontSize:11)` "Étape X / 5"
- Progress bar : height 4 (`AnimatedContainer`), background `bgElev2`, radius `pill`, fill `accent` width `(step/total)*screenWidth`, transition 300ms `Curves.easeOut`
- Padding 18 horizontal

#### 2. RoomsTypeCard (5 instances dans grille 2 colonnes — étape 1)
- Container padding 14, radius `AppRadii.md` (14)
- Border `accent` 1px si `active`, sinon `line`
- Background `accentSoft` si `active`, sinon `bgElev1`
- Label `AppTextStyles.mono` (FontFeature tabular) fontSize 22 w700 lineHeight 1, color `accent` si active sinon `text`
- Subtitle `AppTextStyles.small.copyWith(fontSize:11, height:1.4)` text2 muted

#### 3. SearchableSelect&lt;T&gt; (Ville / Commune)
- Field cliquable : Container padding 14×16 (`AppRadii.sm` 10), border `accent` si open sinon `line`, bg `bgElev2`
- Row : valeur courante (color `text` ou `text3` si placeholder) + Icon chevron `keyboard_arrow_down`/`keyboard_arrow_up` 18 text3
- Au tap → `showModalBottomSheet` (background `bgElev1`, radius top 24, useSafeArea true) :
  - Container padding 18, max height 70% screen
  - Search TextField avec leading `Icons.search` 14 text3, autoFocus
  - `ListView.builder` filtré : InkWell padding 10×10 radius 8 ; si `value === option` background `accentSoft` + color `accent` + icon `Icons.check` 14 (strokeWidth équivalent)
  - Si filtered empty : Text "Aucun résultat pour « X »" small text3 center
- **MVP : pas de "Autre — saisir manuellement"** (option proto avancée out of scope)

#### 4. GpsCaptureCard
État vide :
```
╭───────────────────────────────────────╮
│ ┌──┐                                  │
│ │ 📍│  Position GPS              [Activer GPS]│
│ │  │  Permet de placer le bien...    │
│ └──┘                                  │
╰───────────────────────────────────────╯
   bgElev1 / border line / icon accent
```
État capturé :
```
╭───────────────────────────────────────╮  ← border successLight
│ ┌──┐                                  │
│ │ 📍│  Position enregistrée  [Recapturer]│
│ │  │  5.33640, -4.02670 (mono)        │
│ └──┘                                  │
│ ┌──────────────────────────────────┐ │
│ │  MiniMapPreview (V9.7c)          │ │  ← height 100
│ │       📍 pin centre              │ │
│ └──────────────────────────────────┘ │
╰───────────────────────────────────────╯
   bg success-tinted (alpha 0.06)
```
- Card padding 14, radius `AppRadii.md`, border `successLight` ou `line`, bg `success.withAlpha(0.06)` ou `bgElev1`
- Row gap 12 :
  - Container 44×44 radius 10, bg `successLight` ou `bgElev2`, center `Icon(Icons.place_outlined, size: 20, color: gps != null ? success : accent, strokeWidth: 2)`
  - Expanded Column : label `AppTextStyles.small.copyWith(fontSize:13, fontWeight:w600)` "Position enregistrée" ou "Position GPS" + coords `AppTextStyles.mono(...).copyWith(fontSize:11)` ou body explicatif `AppTextStyles.small.copyWith(fontSize:11, height:1.4)`
  - Button sm : `CustomButton` ou inline button accent (si vide) / outlined (si recapturer), label "Activer GPS"/"Recapturer", padding 8×12 fontSize 11, loading state pendant `isLoadingGeo`
- Si `gps != null` : `MiniMapPreview(center: gps, height: 100)` sous le Row avec marginTop 12

#### 5. WizardStepperRow (Chambres / SdB)
```
┌─ Eyebrow uppercase ────────────────┐
│┌───┬──────────┬───┐                 │
││ − │     1    │ + │                 │
│└───┴──────────┴───┘                 │
└─────────────────────────────────────┘
```
- Column expand (flex 1) :
  - Eyebrow `AppTextStyles.eyebrow` marginBottom 8
  - Container bg `bgElev2`, border `line`, radius `AppRadii.sm` (10), padding 6×8
  - Row spaceBetween :
    - InkWell 28×28 radius 8 bg `bgElev3`, center "−" fontSize 16 w600 color `text` (disabled si value=min, opacity 0.4)
    - Text mono fontSize 16 w600 center
    - InkWell 28×28 radius 8 bg `accent`, center "+" fontSize 16 w700 color `onAccent`

#### 6. AmenityChipGrid
- Column :
  - Eyebrow `AppTextStyles.eyebrow` marginBottom 10
  - GridView count 2 cols, gap 8 mainAxisSpacing/crossAxisSpacing, `shrinkWrap: true`, `physics: NeverScrollable`, `childAspectRatio` ~4.0
  - Chaque AmenityChip = InkWell + Container padding 10×12 radius 10 :
    - Background `accentSoft` si active, `bgElev1` sinon
    - Border `accent` 1px si active, `line` sinon
    - Row gap 8 : Icon `check` 14 strokeWidth 2.6 ou `add` 14 strokeWidth 2 (color matche fg) + Expanded Text fontSize 13 w600/w500 selon active, color `accent`/`text`

#### 7. PhotosUploadCard (Option B : DashedBorderContainer)
```
╔═════════════════════════════════════╗  ← dashed border 1.5px
║                                     ║
║          ╭─────╮                    ║
║          │  +  │  ← cercle 56 accentSoft + icon + accent
║          ╰─────╯                    ║
║    Téléverser depuis l'appareil     ║  ← fontSize 14 w600
║   JPG, PNG, HEIC · max. 10 Mo       ║  ← AppTextStyles.small 12 text3
║                                     ║
╚═════════════════════════════════════╝
```
- `DashedBorderContainer(dashWidth: 5, dashGap: 4, color: line, strokeWidth: 1.5)` (atome existant V7)
- Background `bgElev1` interne, radius `AppRadii.md`
- InkWell wrap pour tap → trigger `image_picker.pickMultiImage()`
- Padding 24, Column center :
  - Container 56×56 circle (`shape: BoxShape.circle`), bg `accentSoft`, center `Icon(Icons.add, size: 26, color: accent, weight: 700)` (Material icons supportent `weight`)
  - SizedBox 12
  - Text "Téléverser depuis l'appareil" `AppTextStyles.small.copyWith(fontSize:14, fontWeight:w600, color:text)`
  - SizedBox 4
  - Text "JPG, PNG, HEIC · max. 10 Mo / photo" `AppTextStyles.small.copyWith(fontSize:12, color:text3)`

#### 8. Photo grid + badge "Couverture" (Option A — chip corner)
```
┌─────────────────────┐
│ ▓COUV               │  ← chip accent abs top-left, padding 3×6 radius sm
│   🖼 Photo 1        │     fontSize 9 w600 color onAccent
│                     │
└─────────────────────┘
┌─────────────────────┐
│   🖼 Photo 2        │  ← pas de badge
│                     │
└─────────────────────┘
```
- Stack :
  - `AspectRatio(1/1, child: ImgPh(tone: ..., radius: 10))` ou `Image.file` si photo locale dispo
  - Position absolute top: 6, left: 6 : Container padding 3×6 bg `accent` radius `sm`, Text "Couverture" `AppTextStyles.eyebrow.copyWith(fontSize: 9, color: onAccent)`
- Compteur Row (au-dessus de la grille) : eyebrow "X photos ajoutées" + chip mini `success.withAlpha(0.14)` "✓ Min. atteint" (couleur success) ou `warn.withAlpha(0.14)` "Y de plus" (couleur warn) fontSize 11 w600

#### 9. PricingCommissionPreview
```
┌──────────────────────────────────────┐
│ Prix client (5 nuits)       225 000  │  ← text2 + mono
│ Commission Asfar (8%)       −18 000  │  ← text2 + mono text3
│ ─────────────────────────────────── │  ← border top line
│ Vous recevez            207 000      │  ← w600 + accent or 14 w700
└──────────────────────────────────────┘
   bgElev2 padding 12 radius md
```
- Container bg `bgElev2`, padding 12, radius `AppRadii.sm` (10)
- 3 Row spaceBetween fontSize 12 :
  - "Prix client (5 nuits)" color text2 + `FcfaFormatter.full(price * 5)` mono
  - "Commission Asfar (8%)" color text2 + `-${FcfaFormatter.full((price * 5 * 0.08).round())}` mono text3
- Border top `line` width 1 marginTop 6 paddingTop 6 :
  - Row : "Vous recevez" fontSize 13 w600 + `FcfaFormatter.full((price * 5 * 0.92).round())` mono fontSize 14 w700 `accent`

#### 10. WizardCtaBar
- Wrap `BlurContainer` existant + Column :
  - `Container` border-top `line` 1px
  - `SafeArea(top: false)` + Padding 14×18×30
  - `CustomButton` lg block :
    - text = `currentStep < totalSteps ? 'Continuer' : 'Publier mon annonce'`
    - onPressed = `canNext ? onContinue : null` (visuel disabled opacity)
    - loading = `isPublishing && currentStep == totalSteps`

#### 11. ResumeDraftDialog
- `AlertDialog` Material override Asfar :
  - `backgroundColor: bgElev1`
  - `shape: RoundedRectangleBorder(borderRadius: AppRadii.md)` (14)
  - Title `AppTextStyles.h3` "Création en cours"
  - Content `AppTextStyles.body` "Vous avez une annonce en cours de création. Reprendre où vous en étiez ?"
  - actions Row 2 colonnes Expanded :
    - `OutlinedCustomButton` "Recommencer" (textColor `text2`) → pop(false) → `DiscardDraft`
    - `CustomButton` "Reprendre" lg block accent → pop(true) → `ResumeDraftDecision(true)`
- Static helper `Future<bool?> show(BuildContext)` qui retourne le choix

#### 12. AsfarToggle (custom proto fidèle)
- StatefulWidget 44×26 :
  - `AnimatedContainer` 200ms `Curves.easeOut` bg `accent` ou `bgElev3` selon value
  - radius `AppRadii.pill` (99), padding 2
  - Aligné start ou end (animation translateX 18→0 ou inverse)
  - Bullet 22×22 radius pill, color blanc
- onChange callback `Function(bool)`

## Layout des écrans d'étape (assemblage atomiques)

**Tous** : `Padding.fromLTRB(18, 0, 18, 24)` + `SingleChildScrollView` (sauf step 3 grille photo)

### Étape 1 — Rooms Type
```dart
Column(crossAxisAlignment: start, children: [
  Text('Combien de pièces ?', style: h2), SizedBox(6),
  Text('Toutes les annonces Asfar...', style: body), SizedBox(18),
  Container( // info card
    padding: 12, bg: accentSoft, border: accent×0.25,
    child: Row [Icon(bolt_outlined, accent), Text('On compte le séjour + chambres...')]
  ), SizedBox(18),
  GridView count 2, gap 10, 5 RoomsTypeCard,
])
```

### Étape 2 — Localisation + Capacité
```
h2 "Localisation"
body "Choisissez la ville, la commune..."
Eyebrow "Titre de l'annonce" + TextField "ex. Belle 2 pièces — Cocody"
SearchableSelect<String> Ville (10 villes CI)
SearchableSelect<String> Commune (adaptatif selon Ville)
Eyebrow "Quartier" + TextField libre "ex. II Plateaux Vallon..."
GpsCaptureCard
Row gap 10 : WizardStepperRow Chambres + WizardStepperRow SdB
Eyebrow "Description (optionnel)" + TextField multilines 100px min
```

### Étape 3 — Photos
```
h2 "Ajoutez des photos"
body "Minimum 3 photos. La première sera la photo de couverture."
PhotosUploadCard (toujours présent en haut, même si déjà uploadé pour ajouter)
Si photos.isNotEmpty :
  Row : eyebrow "X photos ajoutées" + chip success/warn
  GridView count 3, gap 8, photos avec badge corner couv sur première
```

### Étape 4 — Équipements
```
h2 "Équipements"
body "Sélectionnez tout ce que votre logement propose."
AmenityChipGrid eyebrow="Essentiels" (8 items)
AmenityChipGrid eyebrow="Confort" (8 items)
```

### Étape 5 — Prix & conditions
```
h2 "Prix & conditions"
body "Asfar prélève 8% par réservation. Vous gardez le reste."
Card padding 16 :
  Eyebrow "Prix par nuit"
  Row baseline : TextField mono 22 w700 "45 000" + suffix "FCFA / nuit" 14 text3
  Si price : PricingCommissionPreview
Card padding 16 :
  Eyebrow "Frais de ménage (optionnel)"
  TextField mono "5 000"
Card padding 14 :
  Eyebrow "Règles" marginBottom 12
  3 Row spaceBetween (avec border-top sauf premier) :
    "Accepter les démarcheurs (commission 10% sur séjour)" fontSize 13 + AsfarToggle(defaultOn: true)
    "Caution remboursable" + AsfarToggle(defaultOn: true)
    "Animaux acceptés" + AsfarToggle(defaultOn: false)
```

## Constantes UI à figer

| Token | Valeur |
|---|---|
| Step indicator hauteur | 56 (TopNav) + 4 (progress) + 12 (padding bottom) = 72px |
| Step indicator progress | bgElev2 rail, accent fill, height 4, radius 99, transition 300ms |
| CTA bar | BlurContainer + border-top line + padding LRT 18×14, bottom 30 |
| Cards info | padding 12, radius `AppRadii.md` (14), bg `accentSoft`, border `accent` α0.25 |
| Inputs | bgElev2, border `line`, radius `AppRadii.sm` (10), focus border `accent` |
| Cards prix/règles | bg `bgElev1`, border `line`, radius `AppRadii.md` (14) |
| Photos grid | 3 cols, gap 8, aspectRatio 1/1, radius 10 |
| Badge couverture | abs top:6 left:6, padding 3×6, radius `AppRadii.sm`, bg `accent`, fontSize 9 w600 onAccent |

## Accessibilité
- Tap targets : tous ≥ 44×44 (boutons stepper 28×28 mais entourés de padding card)
- Contraste `accent` (#E8B86B) sur `bgElev1` → ratio ~7.5:1 ✓ AAA
- Contraste `text3` (#76767E) sur `bgElev1` → ratio ~5:1 ✓ AA
- Lecteurs d'écran : `Semantics` sur AsfarToggle (`toggled: bool`)

## Performance
- `SingleChildScrollView` par étape (light), pas de `ListView` (5 étapes courtes)
- Photos : décodage Image.file natif Flutter (cached)
- `MiniMapPreview` reuse V9.7c → tile cache OSM partagé
- AnimatedContainer progress bar : layer compositing négligeable
- AsfarToggle : `AnimatedContainer` 200ms 1 frame
