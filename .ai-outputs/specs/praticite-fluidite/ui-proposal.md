# Design UI Validé — praticite-fluidite

> Validé par l'utilisateur le 2026-06-10 (options A + A).

## Option choisie

**① Placeholder image : A — ShimmerCard** (skeleton pulsé existant du design system,
`bgElev2` ↔ `bgElev3`) affiché par `DomainImage` pendant le téléchargement ; l'image
remplace le skeleton à l'arrivée ; en erreur, fallback inchangé sur le `placeholder`
fourni (`ImgPh`).

**② Loader de pagination : A — LoaderCircular** (spinner accent orange existant,
24 px) centré dans un padding de 16 px en pied du feed locataire, visible uniquement
pendant le chargement de la page suivante.

## Composants à créer

- `FavoriteToggleButton` (visuel du cœur existant repris à l'identique — aucune
  modification visuelle, uniquement un changement de granularité de rebuild).

## Composants à réutiliser

- `ShimmerCard` (`lib/widget/loader/shimmer_card.dart`) — placeholder de chargement image
- `LoaderCircular` (`lib/widget/loader/loader_circular.dart`) — pied de liste pagination
- `ImgPh` (`lib/widget/img/img_placeholder.dart`) — fallback erreur (inchangé)

## Amendement au contrat d'architecture

- ❌ Package `shimmer` retiré des dépendances à ajouter (inutile)
- ❌ Widget `ImageShimmerPlaceholder` retiré du contrat (remplacé par `ShimmerCard`)

## Contraintes visuelles

- Fond `#1D1D1D`, cartes `#2A2A2A`, accent `#FFA02A` (AppColors existants)
- Aucune autre modification visuelle dans tout le chantier (RM8 iso-comportement)
