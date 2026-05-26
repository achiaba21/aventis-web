# 📋 Spécification Métier — Alignement Démarcheur sur ReservationDemarcheurDto

**Feature** : `demarcheur-reservation-dto-alignment`
**Date** : 2026-05-21
**Validée par** : utilisateur (cyrillekouakou@gmail.com)
**Mode** : 🔴 Feature Complète

---

## 1. Contexte

Le backend Spring a livré un nouveau DTO `ReservationDemarcheurDto` qui enrichit la réponse de `GET /demarcheur/reservations` avec des objets nested (`proprio`, `appart`, `locataire`, `demarcheur`, `avanceReservation`) et des champs scalaires additionnels (`montantCommission`, `clientExterneNom/Telephone/Email`, `type`).

Le module Démarcheur mobile doit consommer cette nouvelle structure sans perte d'information et offrir au démarcheur les capacités d'identification du proprio et de contact direct sur le détail d'une référence.

## 2. Objectif

Rendre le module Démarcheur cohérent avec la vérité backend :
- Modéliser fidèlement la nouvelle structure côté mobile
- Exposer les informations du propriétaire (identification + contact) sur le détail d'une référence
- Respecter la confidentialité des clients externes des proprios

## 3. Acteurs

- **Démarcheur** : utilisateur connecté qui consulte ses référencements et contacte les proprios des appartements partenaires

## 4. Règles Métier

### R1 — Périmètre des réservations affichées
L'endpoint `GET /demarcheur/reservations` renvoie déjà uniquement les réservations qui concernent le démarcheur connecté. Aucun filtrage par type ou identité n'est à refaire côté mobile : on affiche tout ce que l'API retourne.

### R2 — Identification du propriétaire
Sur le détail d'une référence, le propriétaire est identifié par son nom complet (`proprio.nom` + `proprio.prenom`) et son avatar (`proprio.imgUrl`).

### R3 — Contact du propriétaire
Le détail référence permet au démarcheur de contacter le proprio via le système de contact déjà existant dans l'app, alimenté par `proprio.telephone`. Aucune nouvelle UI de contact à créer.

### R4 — Confidentialité client externe (réservation MANUELLE)
Quand une réservation est de type `MANUELLE` et que le client est un externe passé par le proprio (`clientExterneNom/Telephone/Email` renseignés et `locataire == null`), le démarcheur ne voit PAS les infos du client : seuls l'appartement, les dates, le statut et la commission sont visibles.

### R5 — Type de réservation exposé
Le champ `type` (`DEMARCHEUR` / `PLATEFORME` / `MANUELLE`) doit être disponible dans le modèle mobile. Une distinction visuelle entre « ma demande » (`type=DEMARCHEUR && demarcheur.id=moi`) et « autre » est possible sur la liste si le cas se présente.

### R6 — Nullabilité tolérée
Les champs nullables côté backend (`locataire`, `avanceReservation`, `motif`, `clientExterne*`, `demarcheur`) doivent être gérés sans crash : le parsing mobile reste robuste.

## 5. Cas d'Usage Principal

Le démarcheur ouvre l'onglet « Mes demandes » :
1. La liste s'affiche avec toutes ses référencements
2. Il tape sur une référence → écran détail
3. Il voit : l'appart, les dates, le statut, sa commission, **le nom du propriétaire**, et un bouton de contact qui utilise le téléphone du proprio
4. Il appuie sur le bouton → le système de contact existant lui propose les canaux disponibles

## 6. Cas Alternatifs / Limites

- **Cas A — Réservation MANUELLE avec client externe du proprio** : `locataire == null` ET `clientExterneNom` renseigné → Afficher uniquement appart + dates + statut + commission. Aucune info client visible côté démarcheur.
- **Cas B — Réservation DEMARCHEUR avec client externe (le sien)** : `locataire == null` ET `clientExterneNom` renseigné (cas habituel du démarcheur qui réfère un client externe app) → Comportement actuel conservé : afficher le nom du client externe.
- **Cas C — Réservation où `demarcheur == null`** : Réservation marginale (autre démarcheur sur même appart). L'API peut la renvoyer. Pas de plantage, affichage neutre.
- **Cas D — Champs nested manquants** : Parsing tolérant, valeurs par défaut sûres, pas de crash.

## 7. Contraintes

- **Pas de régression** sur les écrans existants (dashboard, liste référencements, détail référence)
- **Réutilisation maximale** du système de contact déjà présent dans l'app
- **Cohérence avec l'extension `ReferralDisplay`** existante (`status`, `client`, `commission`, `nights`)

## 8. Critères d'Acceptation

- [ ] Le modèle `ReservationDemarcheur` (ou `Reservation`) reflète tous les champs du nouveau payload
- [ ] Le parsing JSON est robuste aux nulls sur tous les champs nullables
- [ ] Le nom complet du proprio (nom + prenom) est affiché sur le détail
- [ ] Le contact du proprio fonctionne via le système existant (téléphone injecté depuis `proprio.telephone`)
- [ ] Sur une réservation MANUELLE avec client externe proprio, aucune info client n'est visible
- [ ] Le champ `type` est disponible et exploitable
- [ ] Aucune réservation existante n'est cassée par le nouveau parsing
- [ ] La commission affichée provient de `montantCommission` du payload
