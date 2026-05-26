# Business Spec — `demarcheur-listing-filters`

**Date :** 2026-05-24

## 1. Contexte
L'écran "Choisir un logement" (`DemarcheurListingsScreen`) affiche tous les logements partenaires sans aucun moyen de les filtrer ou de les situer géographiquement. Le démarcheur doit tout parcourir pour trouver l'appartement adapté au client.

## 2. Objectif
Ajouter un système de filtres combinables (bottom sheet) et un toggle liste/carte sur cet écran.

## 3. Acteurs
Le démarcheur, dans le flow "Nouvelle demande".

## 4. Règles Métier

### Filtres
- **R1** — Bouton "Filtrer" dans l'AppBar ouvre une bottom sheet avec 3 sections : Pièces, Partenaire, Zone
- **R2** — Filtres combinables en AND : seuls les logements vérifiant TOUS les filtres actifs s'affichent
- **R3** — Pièces : chips correspondant aux valeurs `AppartementTypeLocation` présentes dans le dataset (Studio / 2p / 3p / 4p / 5+) — sélection multiple possible
- **R4** — Partenaire : liste des propriétaires uniques dans le dataset — sélection unique
- **R5** — Zone : liste des `communeNom` uniques dans le dataset — sélection unique
- **R6** — Un badge sur le bouton "Filtrer" indique le nombre de filtres actifs (0 = pas de badge)
- **R7** — Bouton "Réinitialiser" dans la bottom sheet efface tous les filtres
- **R8** — Si aucun logement ne correspond aux filtres → `EmptyState.inline` (pas EmptyState.hero)

### Vue carte
- **R9** — Toggle liste/carte dans l'AppBar (icône map ↔ icône list)
- **R10** — Les filtres s'appliquent identiquement aux deux vues
- **R11** — Tap sur un pin de la carte → sélectionne le logement + affiche bottom sheet de confirmation
- **R12** — Bouton "Continuer" sticky visible dans les deux vues si un logement est sélectionné
- **R13** — Vue carte masquée (`if (false)`) jusqu'à ce que le backend expose `lat`/`lon` dans `api/demarcheur/appartements`

### Backend carte (à demander)
- **R14** — Le backend doit ajouter `lat` et `lon` obfusqués dans `AppartementForDemarcheurDto` sur `GET api/demarcheur/appartements`
- **R15** — Coordonnées obfusquées (comme `MapAppartement`) — pas les coords réelles

## 5. Cas d'usage principal
1. Démarcheur ouvre "Choisir un logement" → voit tous les logements
2. Tape "Filtrer" → bottom sheet s'ouvre avec 3 sections
3. Sélectionne "2 pièces" + "Propriétaire Koné" → tape "Appliquer"
4. La liste se réduit aux logements correspondants, badge "2" sur le bouton
5. Tape un logement → calendrier inline apparaît
6. Tape "Continuer" → flow inchangé

## 6. Cas limites
- Dataset avec 1 seul propriétaire → section "Partenaire" masquée dans la bottom sheet
- Dataset avec 1 seule commune → section "Zone" masquée
- Filtres actifs + 0 résultats → EmptyState.inline + bouton "Réinitialiser les filtres"

## 7. Critères d'acceptation
- [ ] Bouton "Filtrer" avec badge dynamique dans l'AppBar
- [ ] Bottom sheet 3 sections, filtres combinables AND
- [ ] Sections masquées si moins de 2 valeurs uniques
- [ ] Réinitialisation complète des filtres
- [ ] Toggle liste/carte masqué (`if (false)`) — prêt à activer quand backend livre coords
- [ ] Infrastructure carte : `Appartement` enrichi `lat/lon`, widgets carte câblés mais conditionnés
- [ ] EmptyState.inline si 0 résultat filtré
