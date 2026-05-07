# Spécification Métier — Calendrier Démarcheur : Plages Concurrentes

## 1. Contexte

Plusieurs démarcheurs peuvent soumettre des demandes de réservation sur le même appartement pour les mêmes dates. Actuellement le calendrier ne montre qu'une seule plage par jour, rendant la concurrence invisible. Le démarcheur doit pouvoir voir les offres concurrentes pour calibrer son prix.

## 2. Objectif

Permettre au démarcheur de visualiser toutes les demandes EN_ATTENTE superposées sur un jour, consulter les prix proposés par les concurrents, et soumettre sa propre offre en connaissance de cause — tout en lui interdisant de dupliquer sa propre demande.

## 3. Acteurs

**Démarcheur** — utilisateur connecté dont le téléphone est disponible via UserBloc.

## 4. Règles Métier

- Un jour peut contenir 0, 1 ou N plages CalendarPlage simultanées
- Un jour OCCUPE est définitivement bloqué, aucune réservation possible
- Un jour avec uniquement des EN_ATTENTE d'autres démarcheurs reste réservable
- Un démarcheur ne peut pas avoir deux demandes EN_ATTENTE sur le même jour pour le même appartement
- L'appartenance d'une plage est déterminée par comparaison de plage.demarcheurTelephone avec user.telephone
- Le serveur fournit demarcheurTelephone dans chaque CalendarPlageDTO

## 5. Les 4 États d'un Jour

| Cas | Condition | Couleur | Action au tap |
|-----|-----------|---------|---------------|
| A | Aucune plage ou DISPONIBLE | Vert | Formulaire direct |
| B | Contient OCCUPE | Rouge | Non clicable |
| C | EN_ATTENTE d'autres uniquement | Orange | Bottom sheet + "Créer ma réservation" |
| D | EN_ATTENTE dont une est la mienne | Amber | Bottom sheet lecture seule |

## 6. Contenu du Bottom Sheet

- Titre : "Demandes en attente — [N demandes]"
- Par entrée : nom démarcheur, téléphone, montant (FCFA), durée (nuits)
- Bouton "Créer ma réservation" : visible seulement en Cas C

## 7. Contraintes

- Pas de nouvelle dépendance package
- Compatibilité avec CalendarPlageBloc existant (ajout minimal)
- La comparaison téléphone est insensible aux espaces/formatage

## 8. Critères d'Acceptation

- [ ] Un jour avec 3 EN_ATTENTE affiche un badge "3" et est orange
- [ ] Cliquer ce jour ouvre le bottom sheet avec 3 entrées
- [ ] Si ma demande est parmi les 3, le jour est amber et le bouton "Créer" absent
- [ ] Un jour OCCUPE est rouge et non clicable
- [ ] Un jour sans plage reste vert et ouvre directement le formulaire
