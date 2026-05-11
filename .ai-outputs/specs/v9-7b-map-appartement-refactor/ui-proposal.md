# 🎨 Proposition UI/UX — V9.7b Map Appartement BottomSheet

> **Version :** 1.0
> **Date :** 2026-05-11
> **Option choisie :** **A — Pristine luxe**
> **Status :** ✅ Validée

---

## Design UI Validé

### Option A — "Pristine luxe"

Shimmer or animé subtil sur ImgPh, sub-line 1 ligne avec séparateur `·`, fallback erreur silencieux. Élégant, identitaire Asfar Premium, comportement uniforme entre loading et erreur (aucune indication d'échec pour préserver l'expérience luxe).

---

## 1. Placement & Wireframe

```
╭──────────────────────────────────────╮
│            ────── (handle)           │
│  ┌────────────────────────────────┐  │
│  │ 🟫🟫🟫 shimmer or animé 🟫🟫🟫 │  │ ← MapMarkerPreviewImage
│  │  (16:9 ImgPh tone base)        │  │   shimmer 1200ms loop
│  └────────────────────────────────┘  │
│  Studio Plateau lumineux             │ ← h3 textPrimary 1 ligne ellipsis
│  40 000 FCFA / nuit · Plateau ·      │ ← small text3 12px 2 lignes max
│  Studio · 0 chambre                  │   ellipsis fin
│                                      │
│  ┌────────────────────────────────┐  │
│  │       Voir détails (CTA or)    │  │ ← CustomButton lg block accent
│  └────────────────────────────────┘  │
╰──────────────────────────────────────╯
   ↑ bgElev1 #131316, top-rounded 24px, useSafeArea
```

- Modal bottom sheet, hauteur ~320px (auto-contenu, `mainAxisSize.min`)
- `showModalBottomSheet`, `backgroundColor: AppColors.bgElev1`
- `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))`
- `padding: EdgeInsets.fromLTRB(18, 8, 18, 24)`

## 2. Composants à Créer

### MapMarkerBottomSheet (refonte)
- Convertit en `StatefulWidget`
- State : `Appartement? _loadedDetails`, `bool _isLoadingDetails = true`, `bool _detailsFailed = false`
- `initState` : appelle `AppartementService.getAppartementById(widget.appartement.id)`. Mise à jour state au succès/échec (toujours `setState` après `mounted` check).
- Drag handle : `Container` 40×4, `color: AppColors.bgElev3`, `borderRadius: 99`
- Photo : `MapMarkerPreviewImage(tone: ..., imgUrl: _loadedDetails?.imgUrl, isLoading: _isLoadingDetails)`
- Titre : `Text(appart.title ?? 'Logement', style: AppTextStyles.h3, maxLines: 1, overflow: ellipsis)`
- Sub-line : `Text(_buildSubLine(), style: AppTextStyles.small.copyWith(fontSize: 12, color: AppColors.text3), maxLines: 2, overflow: ellipsis)`
- CTA : `CustomButton(text: 'Voir détails', onPressed: () => widget.onViewDetails(_loadedDetails), size: ButtonSize.lg, block: true)`

### MapMarkerPreviewImage (nouveau widget extrait)
- StatefulWidget (animation shimmer)
- AspectRatio 16:9, ClipRRect radius 14
- 3 états :
  - **loading** : `Stack` [`ImgPh(tone)`, `ShimmerOverlay` (gradient or translucide qui slide L→R, AnimationController 1200ms repeat)]
  - **loaded** (`imgUrl != null`) : `Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: → fallback)`
  - **error** (loaded mais Image.network errorBuilder déclenché OU loading terminé sans imgUrl) : `ImgPh(tone)` silencieux (PAS d'icône broken_image — option A erreur silencieuse)
- Reçoit : `{required int tone, String? imgUrl, required bool isLoading}`
- Si `isLoading == true` → afficher état loading (peu importe imgUrl)
- Si `isLoading == false && imgUrl != null` → état loaded
- Si `isLoading == false && imgUrl == null` → état error (silencieux = juste ImgPh)

### ShimmerOverlay (sous-widget interne au fichier MapMarkerPreviewImage)
- AnimatedBuilder qui anime un `LinearGradient` translucide accent
- Gradient : `[transparent, accentSoft, transparent]` avec stops qui glissent de -0.3 → 1.3 sur l'axe X
- AnimationController 1200ms, `Curves.linear`, `repeat: true`
- BlendMode `srcATop` pour rester contenu dans le ClipRRect
- `dispose` propre du controller

## 3. Composants à Réutiliser

- `ImgPh` (placeholder gradient tonal) — pour base et fallback erreur
- `CustomButton` + `ButtonSize.lg` — CTA "Voir détails"
- `FcfaFormatter.full(price)` — formatage prix "40 000 FCFA"
- `AppColors` : `bgElev1`, `bgElev3`, `accent`, `accentSoft`, `text`, `text3`, `line`
- `AppTextStyles` : `h3` (titre), `small.copyWith(fontSize: 12)` (sub-line)
- `AppRadii` : `lg` (14) pour photo, `99` (handle)

## 4. Sub-line — Format exact

Helper `_buildSubLine(MapAppartement m, Appartement? loaded) → String` :

```
parts = []
price = loaded?.prix ?? m.price
if (price != null && price > 0) parts.add('${FcfaFormatter.full(price)} / nuit')

commune = m.communeName?.trim()
if (commune?.isNotEmpty == true) parts.add(commune)

type = m.typeAppart?.trim()
if (type?.isNotEmpty == true) parts.add(type)

nbCh = m.nbChambres
if (nbCh != null && nbCh > 0) {
  parts.add('$nbCh ${nbCh == 1 ? 'chambre' : 'chambres'}')
} else if (nbCh == 0) {
  // Studio : on l'a déjà dans typeAppart, on n'ajoute pas "0 chambre"
}

return parts.join(' · ')
```

Exemples :
- `40 000 FCFA / nuit · Plateau · STUDIO`
- `65 000 FCFA / nuit · Cocody · DEUX_PIECES · 2 chambres`
- `Plateau · STUDIO` (si pas de prix)

## 5. Contraintes Visuelles

| Élément | Spec |
|---|---|
| Fond sheet | `AppColors.bgElev1` (#131316) |
| Handle | `AppColors.bgElev3` (#25252B), 40×4, radius 99 |
| Photo base | `ImgPh` selon tone `(id % 4) + 1` |
| Shimmer gradient | `[Colors.transparent, AppColors.accentSoft, Colors.transparent]` |
| Shimmer durée | 1200ms, repeat infini, `Curves.linear` |
| Photo radius | `AppRadii.lg` = 14 |
| Photo aspect | 16:9 strict |
| Titre style | `AppTextStyles.h3`, color `text`, maxLines 1 |
| Sub-line style | `AppTextStyles.small.copyWith(fontSize: 12, color: text3)`, maxLines 2 |
| CTA | `CustomButton lg block`, accent or, label "Voir détails" |
| Top sheet radius | 24px |
| Padding | `EdgeInsets.fromLTRB(18, 8, 18, 24)` |
| Spacing handle → photo | 16px |
| Spacing photo → titre | 14px |
| Spacing titre → sub-line | 4px |
| Spacing sub-line → CTA | 18px |

## 6. Comportements

| Cas | Comportement visuel |
|---|---|
| Tap marker → sheet apparaît | Shimmer commence immédiatement, getAppartementById en cours |
| Détail chargé avec imgUrl | Photo glisse en place (Image.network), shimmer s'arrête |
| Détail chargé sans imgUrl | Reste sur ImgPh tone, shimmer s'arrête |
| Échec chargement détail | Reste sur ImgPh tone, shimmer s'arrête, CTA reste actif (push fallback partial mapper) |
| Image.network errorBuilder | Fallback silencieux sur ImgPh tone |
| Tap CTA pendant loading | Push détail avec mapper fallback partial (l'utilisateur peut anticiper) |

## 7. Accessibilité

- Contraste titre `text` (#F5F5F7) sur `bgElev1` (#131316) → ratio 17.5:1 ✓ AAA
- Contraste sub-line `text3` (#76767E) sur `bgElev1` → ratio 4.8:1 ✓ AA
- CTA `accent` (#E8B86B) avec texte `onAccent` (#1A1206) → ratio 11.8:1 ✓ AAA
- Tap target CTA : 48px hauteur min (ButtonSize.lg garantit)
- Drag handle visible et atteignable

## 8. Performance

- Une seule `AnimationController` par sheet (instanciée à l'ouverture, disposée à la fermeture)
- Pas de `setState` pendant l'animation shimmer (utiliser `AnimatedBuilder`)
- `Image.network` avec cache HTTP standard (DefaultImageCache)
- Pas de précache nécessaire (photo lazy = c'est le but)
