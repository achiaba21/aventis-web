# Spécification Métier : Localisation Proprio

## 1. Contexte

Le widget `ResidenceMapSection` affiche actuellement le même message "Réserver pour voir l'adresse exacte" pour tous les utilisateurs, y compris le propriétaire. Cela est incorrect car le proprio doit pouvoir voir et modifier la localisation de sa propre résidence.

## 2. Objectif

- Différencier l'affichage selon le rôle (proprio vs locataire)
- Permettre au proprio de renseigner/modifier la localisation de sa résidence
- Afficher une carte approximative au locataire si pas de localisation exacte

## 3. Acteurs

| Acteur | Actions |
|--------|---------|
| **Propriétaire** | Voir, ajouter, modifier la localisation de sa résidence |
| **Locataire** | Voir la localisation (exacte si payé, approximative sinon) |

## 4. Règles Métier

| Règle | Description |
|-------|-------------|
| RM1 | Le proprio voit TOUJOURS les coordonnées exactes de sa résidence |
| RM2 | Le proprio peut ajouter/modifier la localisation à tout moment |
| RM3 | Le locataire sans réservation payée voit la carte centrée sur la commune |
| RM4 | Le locataire avec réservation payée voit les coordonnées exactes |
| RM5 | La saisie de localisation propose plusieurs méthodes : recherche adresse, carte cliquable, saisie manuelle |

## 5. Cas d'Usage Principal

### Proprio - Ajouter une localisation manquante

1. Proprio ouvre le détail de sa résidence
2. La section "Localisation" affiche "Ajouter la localisation"
3. Proprio clique → écran de saisie s'ouvre
4. Proprio choisit une méthode :
   - Recherche adresse (autocomplétion)
   - Cliquer sur la carte
   - Saisie manuelle GPS
5. Proprio valide → coordonnées sauvegardées
6. La carte s'affiche avec le marqueur exact

### Locataire - Consulter sans localisation exacte

1. Locataire ouvre le détail d'une résidence
2. La résidence n'a pas de coordonnées exactes visibles pour lui
3. La carte s'affiche centrée sur la commune (zoom dézoomé)
4. Message : "Localisation approximative - Quartier X"

## 6. Cas Alternatifs / Limites

| Cas | Comportement |
|-----|--------------|
| Proprio modifie localisation existante | Même écran de saisie, pré-rempli avec les valeurs actuelles |
| Géocodage échoue | Proposer les autres méthodes (carte, manuel) |
| Pas de commune connue | Afficher placeholder "Localisation non renseignée" |

## 7. Contraintes

- Utiliser le `GeocodingService` existant pour la recherche adresse
- Respecter le pattern existant du projet
- Pas de nouvelle dépendance externe

## 8. Critères d'Acceptation

- [ ] Le proprio ne voit plus "Réserver" sur ses propres résidences
- [ ] Le proprio peut ajouter une localisation via 3 méthodes
- [ ] Le proprio peut modifier une localisation existante
- [ ] Le locataire voit la carte approximative (commune) si pas de coords exactes
- [ ] Les coordonnées sont sauvegardées sur le serveur

---

**Validé par l'utilisateur** : Oui
**Date** : 2025-12-27
