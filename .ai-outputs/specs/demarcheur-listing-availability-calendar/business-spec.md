# Business Spec — `demarcheur-listing-availability-calendar`

**Date :** 2026-05-24

## Contexte
Dans le flow "Nouvelle demande" démarcheur, l'écran "Choisir un logement" (`DemarcheurListingsScreen`) affiche une liste d'appartements. Le démarcheur manque de visibilité sur les disponibilités avant de choisir.

## Objectif
Quand un logement est sélectionné (radio button), afficher inline un mini-calendrier en lecture seule montrant les jours réservés (rouge) vs libres. Navigation prev/next mois à partir du mois courant.

## Règles métier
- R1 : Calendrier purement informatif — aucune sélection de date
- R2 : Données via `CalendarService.getDemarcheurCalendar` au moment de la sélection
- R3 : Navigation mois : mois courant = borne min (impossible d'aller avant)
- R4 : Réutiliser `MiniCalendarGrid` existant (cohérence visuelle, 0 duplication)
- R5 : Flow après "Continuer" inchangé → `DemarcheurAppartDetailScreen`
- R6 : Un seul logement sélectionné à la fois

## Critères d'acceptation
- [ ] Sélection d'un logement affiche le calendrier inline
- [ ] Jours réservés en rouge, libres en neutre
- [ ] Prev/next mois fonctionnels, mois courant = borne min
- [ ] Changer de logement charge le calendrier du nouveau
- [ ] Bouton "Continuer" navigue vers `DemarcheurAppartDetailScreen`
- [ ] Réutilisation effective de `MiniCalendarGrid` (0 duplication)
