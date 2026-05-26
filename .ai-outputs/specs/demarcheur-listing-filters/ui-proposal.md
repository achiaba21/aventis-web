# UI Proposal — `demarcheur-listing-filters`

**Date :** 2026-05-24
**Option choisie :** Écran filtre pleine page + pickers bottom sheet

## Placement
Bouton "⚙ Filtrer" dans l'AppBar de `DemarcheurListingsScreen` → `pushScreen(ListingFilterScreen)`.

## Composants à créer
- `listing_filter_screen.dart` — écran filtre plein avec 3 sections
- `listing_partenaire_picker.dart` — bottom sheet tiles (pattern ChargeAppartementPicker)
- `listing_zone_picker.dart` — bottom sheet tiles (même pattern)

## Composants à réutiliser
- `AsfarChip` — chips Pièces multi-select (Wrap)
- Pattern `ChargeAppartementPicker` — tiles + coche accent pour Partenaire et Zone
- `DynamicAppBar` — titre "Filtres" + trailing "Réinitialiser"
- `AppTextStyles.eyebrow` — titres de sections

## Contraintes visuelles
- Bouton AppBar : icône tune + label "Filtrer" + badge accent numérique (masqué si 0)
- Sections avec `AppTextStyles.eyebrow` (ex : "PIÈCES", "PARTENAIRE", "ZONE")
- Row picker : fond bgElev1, border line, chevron_right, valeur active en accent
- Row picker : label "Tous les partenaires" / "Toutes les zones" si aucune sélection
- Bouton "Appliquer" sticky avec count dynamique "(X résultats)"
- Bouton "Réinitialiser" dans trailing de l'AppBar — visible uniquement si filtres actifs
