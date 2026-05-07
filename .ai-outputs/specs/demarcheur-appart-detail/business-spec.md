# Spécification Métier — Écran Détail Appartement Démarcheur

## 1. Contexte

Le démarcheur accède actuellement aux appartements partenaires via une liste minimaliste (titre + prix) qui le redirige directement vers un calendrier, sans aucune information sur l'appartement. Ce manque d'information oblige le démarcheur à naviguer sans contexte et crée une friction inutile.

## 2. Objectif

Créer un écran unique et scrollable qui centralise toutes les informations utiles sur un appartement **et** son calendrier de disponibilité, réduisant le parcours de 2 écrans à 1.

## 3. Acteurs

**Démarcheur** — agent commercial qui prospecte des clients pour le compte de propriétaires partenaires.

## 4. Règles Métier

- L'écran affiche les informations de l'appartement **sans la section commentaires**
- Si l'appartement a des photos → afficher le carousel
- Si l'appartement n'a pas de photos → afficher directement les infos texte (pas de placeholder)
- Le calendrier est toujours visible en bas de l'écran (après scroll)
- Taper sur un jour disponible (Cas A ou C) ouvre le formulaire de réservation en **nouvel écran (push)**
- Les cas B (occupé) restent non-cliquables
- Le cas D (propre demande en attente) affiche le bottom sheet en lecture seule
- Le cas C (concurrence) affiche le bottom sheet + bouton "Créer ma réservation"

## 5. Cas d'Usage Principal

1. Le démarcheur tape sur une card dans la liste des appartements
2. L'écran de détail s'ouvre avec les photos (si disponibles) puis les infos
3. Il scrolle pour voir : description → règles → capacité (lits/chambres/douches)
4. Il continue à scroller jusqu'au calendrier
5. Il navigue entre les mois via les flèches
6. Il tape sur un jour disponible → formulaire de réservation (écran push)
7. Il soumet la réservation → retour à l'écran de détail

## 6. Cas Limites

- Appartement sans photos → infos texte directement en haut
- Appartement sans description → section masquée
- Appartement sans règles → section masquée
- Chargement du calendrier en cours → indicateur de chargement dans la section calendrier uniquement
- Erreur de chargement calendrier → message d'erreur avec bouton retry dans la section calendrier

## 7. Contraintes

- Ne pas modifier les widgets existants (`AppartDetailContent`, `AppartDetailHeader`)
- Ne pas modifier `DemarcheursEnAttenteBottomSheet`
- `DemarcheurCalendarScreen` supprimé après migration
- Pas de commentaires dans cette version

## 8. Critères d'Acceptation

- [ ] Tap sur une card → ouvre `DemarcheurAppartDetailScreen`
- [ ] Photos affichées si disponibles, infos texte directement sinon
- [ ] Description, règles, nbLits/chambres/douches visibles
- [ ] Calendrier scrollable en bas de page, fonctionnel (navigation mois + 4 cas)
- [ ] Tap jour dispo → `DemarcheurReservationFormScreen` en push
- [ ] `DemarcheurCalendarScreen` supprimé
