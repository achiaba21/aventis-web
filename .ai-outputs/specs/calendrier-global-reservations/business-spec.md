# 📋 Spécification Métier - Calendrier Global des Réservations

## 1. Contexte

Les propriétaires ont actuellement des difficultés à :
- Visualiser l'occupation globale de leur portfolio
- Planifier les arrivées et départs
- Naviguer efficacement entre les appartements pour consulter les réservations

Un module de calendrier centralisé dans la bottom navigation permettra de résoudre ces problèmes en offrant une vue d'ensemble instantanée et des actions rapides.

## 2. Objectif

Créer un module de calendrier global accessible depuis la bottom navigation qui permet aux propriétaires de :
- Visualiser toutes leurs réservations sur un seul écran
- Naviguer facilement entre différentes échelles de temps (année/mois/jours)
- Gérer rapidement leurs réservations (consulter, créer, confirmer)
- Identifier en un coup d'œil les périodes d'occupation et les actions à effectuer

## 3. Acteurs

**Propriétaires** possédant un ou plusieurs appartements/résidences

## 4. Règles Métier

### RM1 - Affichage des réservations
- Afficher TOUTES les réservations SAUF celles avec statut "Annulée"
- Statuts affichés : Confirmée, En attente, Payée, Finalisée

### RM2 - Code couleur
- Chaque appartement/résidence a une couleur unique
- Facilite l'identification rapide dans le calendrier global

### RM3 - Détection de conflits
- Lors de la création d'une réservation, détecter automatiquement les chevauchements
- Bloquer la création si conflit détecté
- Afficher un message d'erreur explicite avec les dates en conflit

### RM4 - Navigation par niveaux
- 3 niveaux de zoom : Année → Mois → Jours
- Impossible de descendre en dessous du niveau "Jours"
- Geste natif : pinch-to-zoom (écarter/resserrer 2 doigts) pour changer de niveau

### RM5 - Taux d'occupation
- Calcul dynamique : (jours occupés / jours total) × 100
- Affichage en haut du calendrier selon le niveau actif

## 5. Cas d'Usage Principal

### Scénario 1 : Consultation de l'occupation globale

1. Le propriétaire ouvre l'app et clique sur l'onglet "Calendrier" (bottom nav)
2. Le calendrier s'affiche par défaut en vue "Mois" sur le mois en cours
3. Il voit :
   - Toutes ses réservations avec code couleur par appartement
   - Le taux d'occupation du mois en haut (ex: "78% occupé")
   - Badge de notification pour réservations en attente (ex: "3 en attente")
   - Indicateurs d'arrivées (↓) et départs (↑) du jour
4. Il effectue un geste de pinch (resserrer 2 doigts) → Vue "Année" (12 mois)
5. Il effectue un geste de pinch inversé (écarter 2 doigts) → Vue "Jours" (détail du mois)
6. Il clique sur une réservation → Navigation vers écran de détail
7. Il clique sur bouton "+" → Création d'une nouvelle réservation
8. Il appuie longuement sur une réservation en attente → Actions rapides (Confirmer/Voir détails)

### Scénario 2 : Création d'une réservation

1. Depuis le calendrier, clic sur bouton "Créer réservation"
2. Sélection de l'appartement
3. Sélection des dates de début et fin
4. **Validation automatique** : Vérification des conflits
5. Si conflit → Message d'erreur : "Conflit détecté : Appartement déjà réservé du [date] au [date]"
6. Si OK → Suite du processus de création

## 6. Fonctionnalités Différenciantes

### Navigation et Visualisation
- ✅ Système de zoom à 3 niveaux (Année/Mois/Jours) avec pinch-to-zoom
- ✅ Bouton "Aujourd'hui" pour retour rapide à la date actuelle
- ✅ Code couleur par appartement pour identification rapide
- ✅ Indicateurs visuels : arrivées (↓ vert) et départs (↑ rouge) du jour
- ✅ Durée de séjour affichée sur chaque réservation (ex: "3n")

### Indicateurs de Performance
- ✅ Taux d'occupation global affiché en haut
- ✅ Badge de notification pour réservations en attente

### Sécurité et Contrôle
- ✅ Détection automatique des conflits de dates
- ✅ Alerte visuelle lors de tentative de double réservation

### Actions Rapides
- ✅ Appui long pour menu contextuel (Confirmer/Voir détails)
- ✅ Navigation directe vers détail de réservation

## 7. Cas Alternatifs / Limites

### Cas 1 : Aucune réservation
- Afficher un message : "Aucune réservation pour cette période"
- Bouton "Créer ma première réservation"

### Cas 2 : Propriétaire avec 1 seul appartement
- Pas de légende de couleurs nécessaire
- Affichage simplifié

### Cas 3 : Propriétaire avec 10+ appartements
- Légende de couleurs avec scroll si nécessaire
- Filtre par appartement/résidence pour simplifier la vue

### Cas 4 : Conflit lors de la création
- Bloquer la création
- Afficher message d'erreur avec détails du conflit
- Proposer des dates alternatives (optionnel v2)

### Cas 5 : Données non chargées
- Si ReservationBloc n'est pas encore loaded → Afficher loader
- Écouter le BLoC et rafraîchir automatiquement dès que loaded
- Pas de consultation hors ligne nécessaire (données toujours en mémoire)

## 8. Contraintes

### Performance
- Le calendrier doit s'afficher instantanément (< 500ms)
- Scrolling fluide à 60fps minimum
- Optimisation pour les propriétaires avec 50+ réservations
- **Aucun appel serveur nécessaire** : toutes les données proviennent du ReservationBloc déjà chargé en mémoire

### Ergonomie
- Respect des standards iOS/Android pour le pinch-to-zoom
- Gestes natifs reconnus instantanément
- Transitions fluides entre les niveaux de zoom

### Données
- Source unique : **ReservationBloc** (données déjà en mémoire)
- Écoute des changements du BLoC pour rafraîchissement automatique
- Pas d'appels API redondants

### Accessibilité
- Respecter les contrastes WCAG pour les daltoniens
- Texte alternatif pour les codes couleur
- Support des lecteurs d'écran

## 9. Critères d'Acceptation

### Vue et Navigation
- [ ] Le calendrier est accessible depuis la bottom navigation
- [ ] 3 niveaux de zoom fonctionnels : Année/Mois/Jours
- [ ] Geste pinch-to-zoom fonctionne dans les deux sens
- [ ] Bouton "Aujourd'hui" ramène à la date actuelle
- [ ] Transition fluide entre les vues (animation < 300ms)

### Affichage des Réservations
- [ ] Toutes les réservations (sauf annulées) sont affichées
- [ ] Chaque appartement a une couleur unique
- [ ] Durée de séjour visible sur chaque réservation (ex: "3n")
- [ ] Légende des couleurs affichée (si 2+ appartements)

### Indicateurs
- [ ] Taux d'occupation affiché en haut selon la vue active
- [ ] Badge de notification pour réservations en attente
- [ ] Indicateurs d'arrivées (↓ vert) et départs (↑ rouge) du jour

### Actions
- [ ] Clic sur réservation → Navigation vers détail
- [ ] Appui long → Menu contextuel (Confirmer/Voir détails)
- [ ] Bouton "+" pour créer une nouvelle réservation
- [ ] Création bloquée si conflit détecté
- [ ] Message d'erreur explicite en cas de conflit

### Filtres
- [ ] Filtre par statut (Confirmée/En attente) fonctionnel
- [ ] Statut "Annulée" exclu par défaut

### Performance
- [ ] Affichage initial < 500ms (pas d'appel serveur)
- [ ] Scrolling à 60fps
- [ ] Gestes reconnus instantanément (< 100ms)
- [ ] Rafraîchissement automatique lors des changements du ReservationBloc

## 10. Sources et Recherches

### Besoins du marché identifiés
- Vue centralisée de toutes les réservations sur un seul écran
- Prévention des doubles réservations
- Gestion visuelle des arrivées/départs
- Filtres et vues personnalisables
- Automatisation des tâches récurrentes

### Fonctionnalités des solutions leaders
1. Calendrier unifié pour portfolio complet
2. Vues flexibles (jour/semaine/mois)
3. Indication visuelle du statut (confirmé/en attente/annulé)
4. Navigation rapide vers détails réservation
5. Filtres par appartement/résidence/statut/période
6. Export et rapports

### Références
- [HousingAnywhere Calendar](https://housinganywhere.com/calendar)
- [Lodgify Vacation Rental Calendar](https://www.lodgify.com/blog/vacation-rental-calendar/)
- [Calendrier réservations Lodgify FR](https://www.lodgify.com/blog/fr/calendrier-location-saisonniere/)
- [GetApp Property Management Software](https://www.getapp.com/real-estate-property-software/property-management/f/calendar-management/)

---

**Date de validation** : 2026-02-12
**Validé par** : Utilisateur
**Statut** : ✅ Validé - Prêt pour architecture
