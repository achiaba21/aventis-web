# Spécification métier — Intégration modération annonces (mobile + backend)

Feature : `moderation-annonces-mobile`
Date : 2026-05-31
Repos impactés : `app` (Flutter, principal) + `serveur` (Spring Boot, pour l'item #4)

## 1. Contexte

Côté propriétaire, le statut de modération renvoyé par le backend
(`EN_COURS` / `EN_LIGNE` / `HORS_LIGNE`) n'est ni parsé, ni affiché, et l'annonce
hors ligne ne peut pas être resoumise. Les écrans existent côté mobile mais
l'intégration est cassée ou absente. De plus, le propriétaire doit pouvoir mettre
lui-même son annonce hors ligne.

## 2. Acteur

Le **propriétaire** (gestion de ses propres annonces).

## 3. Contrat backend confirmé (lu dans le code serveur)

- `AppartementStatus` = `EN_COURS` (en attente de modération), `EN_LIGNE`
  (approuvé / visible), `HORS_LIGNE` (rejeté, désactivé ou retiré).
- `POST /api/proprietaire/appartement/{id}/resoumettre` : `HORS_LIGNE → EN_COURS`
  (body vide, réponse `ResponseServeur { body, message }`). **Existe.**
- Le passage `EN_LIGNE → HORS_LIGNE` (`DESACTIVE`) est aujourd'hui **réservé à
  l'admin**. **Il n'existe pas** d'endpoint propriétaire pour ce passage → à créer.
- Aucun endpoint propriétaire n'expose le **motif** de rejet (hors scope).

## 4. Règles métier

1. **Enum union (non destructif)** : ajouter `EN_COURS`, `EN_LIGNE`,
   `HORS_LIGNE` à l'enum Flutter `AppartementStatus`, en **conservant** les
   valeurs existantes (`DISPONIBLE`, `OCCUPE`, `EN_MAINTENANCE`, `INACTIF`).
   Aucune de ces 4 n'a le même sens que les 3 nouvelles → pas de doublon, pas
   de suppression.
2. Le parsing `fromString` doit résoudre les 3 valeurs backend (fonctionne par
   `name`, donc OK une fois les valeurs ajoutées).
3. Le badge de statut doit refléter le **vrai** statut, plus aucun libellé en dur.
4. Bouton « Resoumettre » visible **uniquement** si `status == HORS_LIGNE`
   → l'annonce repasse `EN_COURS`.
5. Bouton « Mettre hors ligne » visible **uniquement** si `status == EN_LIGNE`
   → l'annonce passe `HORS_LIGNE` (action initiée par le propriétaire).

## 5. Choix UX validés

- Libellés + couleurs des nouveaux statuts :
  - `EN_COURS` → « EN VALIDATION » (orange / warning)
  - `EN_LIGNE` → « EN LIGNE » (vert / success)
  - `HORS_LIGNE` → « HORS LIGNE » (rouge / danger)
  - Les 4 libellés existants restent inchangés.
- Resoumission : dialog de confirmation → appel API → snackbar succès →
  rafraîchissement.
- Mise hors ligne : symétrique (confirmation → appel → snackbar → refresh).
  Côté backend : motif auto « Mise hors ligne par le propriétaire », **pas** de
  notification (le propriétaire agit lui-même).
- Motif de rejet : message générique sur l'écran d'une annonce `HORS_LIGNE`
  (« Votre annonce a été mise hors ligne. Modifiez-la si besoin, puis
  resoumettez-la. »), UI structurée pour brancher le motif réel plus tard.

## 6. Cas d'usage

1. Le proprio ouvre ses annonces → chaque carte affiche le bon badge.
2. Annonce `EN_LIGNE` → bouton « Mettre hors ligne ».
3. Annonce `HORS_LIGNE` → bouton « Resoumettre » + message générique.
4. Clic sur une action → confirmation → appel API → succès → statut mis à jour,
   liste rafraîchie.

## 7. Cas limites / erreurs

- Statut inconnu / `null` → badge neutre « ANNONCE » (comportement actuel).
- Échec réseau → snackbar d'erreur, statut inchangé.
- Action sur un statut non conforme → message d'erreur backend remonté tel quel.

## 8. Critères d'acceptation

- [ ] L'enum contient les 7 valeurs ; `fromString("EN_LIGNE")` etc. ne renvoie
      plus `null`.
- [ ] Les cartes (`listing_full_card_hero`, `proprio_listing_row`) et l'écran
      d'édition affichent le statut dynamique.
- [ ] `AppartementService.resoumettre(id)` appelle le bon endpoint ; event bloc
      + bouton conditionnel (`HORS_LIGNE`) présents.
- [ ] Nouvel endpoint backend `EN_LIGNE → HORS_LIGNE` côté propriétaire ;
      `AppartementService.mettreHorsLigne(id)` + event bloc + bouton conditionnel
      (`EN_LIGNE`).
- [ ] Resoumission et mise hors ligne fonctionnelles avec feedback et
      rafraîchissement.

## 9. Hors scope

- Affichage du motif réel de rejet/désactivation (nécessite un endpoint backend
  dédié, à planifier séparément).
- Modération côté admin (déjà en place).
