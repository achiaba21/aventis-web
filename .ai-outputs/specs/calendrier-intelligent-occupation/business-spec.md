# 📋 Spécification Métier : Calendrier Intelligent d'Occupation

**Date :** 2026-02-12
**Agent :** Business Analyst
**Statut :** ✅ Validé par l'utilisateur

---

## 1. Contexte

Actuellement, il n'existe pas de vue calendaire permettant de visualiser rapidement les périodes d'occupation des appartements et résidences. Cela rend difficile :
- Pour les locataires : identifier les dates disponibles pour réserver
- Pour les propriétaires : avoir une vue d'ensemble de l'occupation de leurs biens

---

## 2. Objectif

Fournir un calendrier visuel mensuel avec code couleur permettant de visualiser l'occupation des appartements/résidences et d'interagir différemment selon le rôle de l'utilisateur (locataire ou propriétaire).

---

## 3. Acteurs

- **Locataire** : Consulte le calendrier pour voir les périodes occupées d'un appartement et éviter de sélectionner ces dates lors de la réservation
- **Propriétaire** : Consulte le calendrier de ses appartements/résidences, peut cliquer sur les périodes occupées pour accéder aux détails de réservation

---

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **Seules réservations confirmées** | Seules les réservations avec statut "confirmé" apparaissent comme occupées |
| RM2 | **Vue mensuelle** | Le calendrier affiche un mois complet à la fois |
| RM3 | **Deux modes d'affichage** | Calendrier accepte soit un appartement (1 seul), soit une résidence (tous ses appartements) en paramètre |
| RM4 | **Mode résidence réservé au proprio** | Seul le propriétaire peut afficher le calendrier au niveau résidence (vue multi-appartements) |
| RM5 | **Bande de couleur par appartement** | Chaque jour occupé affiche une **bande fine** de la couleur de l'appartement (pas toute la case colorée) |
| RM6 | **Persistance couleur durant session** | Une fois attribuée, la couleur d'un appartement reste identique jusqu'à déconnexion |
| RM7 | **Dates occupées non sélectionnables** | Pour le locataire, les dates occupées ne peuvent pas être sélectionnables |
| RM8 | **API dédiée** | Une API backend fournit les plages d'occupation d'un appartement donné |

---

## 5. Cas d'Usage Principal

### CU1 : Locataire consulte disponibilités d'un appartement

**Préconditions :**
- Utilisateur connecté en tant que locataire
- Appartement sélectionné pour consultation

**Scénario :**
1. Le locataire accède à la page de détail d'un appartement
2. Le système affiche le calendrier mensuel de cet appartement
3. Le système appelle l'API pour récupérer les plages d'occupation
4. Le système affiche les périodes occupées avec une bande fine de couleur
5. Le locataire visualise les dates disponibles
6. Le locataire ne peut pas sélectionner les dates occupées

**Postconditions :**
- Le locataire connaît les périodes disponibles pour réserver

---

### CU2 : Propriétaire consulte l'occupation d'une résidence

**Préconditions :**
- Utilisateur connecté en tant que propriétaire
- Propriétaire possède la résidence concernée

**Scénario :**
1. Le propriétaire accède au calendrier de sa résidence
2. Le système affiche le calendrier mensuel
3. Le système appelle l'API pour chaque appartement de la résidence
4. Le système génère une couleur aléatoire pour chaque appartement (une seule fois par session)
5. Le système affiche toutes les périodes occupées avec une bande fine de couleur correspondante
6. Le propriétaire clique sur une période occupée
7. Le système affiche les détails de la réservation
8. Le propriétaire peut naviguer vers la page complète de la réservation

**Postconditions :**
- Le propriétaire a une vue d'ensemble de l'occupation de sa résidence

---

## 6. Cas Alternatifs

| Cas | Condition | Comportement |
|---|---|---|
| CA1 | Aucune réservation confirmée | Le calendrier affiche toutes les dates du mois normalement, mais aucun jour n'est coloré (tous restent neutres/sans couleur de résidence) |
| CA2 | Navigation mois suivant/précédent | Le système recharge les données d'occupation pour le nouveau mois |
| CA3 | Résidence avec nombreux appartements | Le système affiche tous les appartements avec couleurs distinctes (légende si nécessaire) |
| CA4 | Locataire tente d'afficher calendrier résidence | Le système refuse et affiche uniquement le calendrier par appartement |

---

## 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|---|---|---|
| E1 | API occupation injoignable | Afficher message "Impossible de charger les disponibilités" + calendrier vide |
| E2 | Appartement/résidence inexistant(e) | Afficher message "Bien immobilier introuvable" |
| E3 | Propriétaire accède à résidence d'un autre | Bloquer l'accès + message "Vous n'êtes pas propriétaire de cette résidence" |

---

## 8. Contraintes

- **Performance :** Le calendrier doit se charger en moins de 2 secondes
- **UX :** Les couleurs doivent être suffisamment contrastées pour être distinguables
- **Accessibilité :** Ne pas se fier uniquement aux couleurs (texte/icônes en complément si possible)

---

## 9. Critères d'Acceptation

- [ ] Le calendrier affiche une vue mensuelle complète
- [ ] L'API retourne les plages d'occupation (dates début-fin) pour un appartement donné
- [ ] Seules les réservations confirmées apparaissent comme occupées
- [ ] Chaque appartement a une couleur distincte générée aléatoirement
- [ ] La couleur reste identique durant toute la session utilisateur
- [ ] Le propriétaire peut afficher le calendrier d'une résidence entière (multi-appartements)
- [ ] Le locataire ne voit que le calendrier d'un appartement unique
- [ ] Le locataire ne peut pas sélectionner les dates occupées
- [ ] Le propriétaire peut cliquer sur une période occupée pour voir les détails
- [ ] Le propriétaire peut naviguer vers la réservation depuis le calendrier
- [ ] La navigation entre mois fonctionne correctement
- [ ] Les erreurs sont gérées avec messages explicites
- [ ] Les jours occupés affichent une bande fine de couleur (pas toute la case)
- [ ] Plusieurs appartements d'une même résidence peuvent avoir leurs bandes de couleur superposées/juxtaposées sur un même jour

---

## 10. Hors Périmètre

- ❌ Gestion des réservations en attente/demande (uniquement confirmées)
- ❌ Personnalisation des couleurs par l'utilisateur
- ❌ Vue hebdomadaire ou annuelle (uniquement mensuelle)
- ❌ Création/modification de réservation depuis le calendrier
- ❌ Filtrage par statut de réservation
- ❌ Export du calendrier (PDF, iCal, etc.)

---

## 11. Points Clés pour l'Architecture

- Le calendrier est **toujours visible** avec toutes les dates du mois
- Les jours **occupés** affichent une bande fine de couleur
- Les jours **libres** restent neutres (sans couleur)
- Génération aléatoire de couleurs à conserver en session (stockage temporaire nécessaire)
- API backend à définir pour récupérer les plages d'occupation
