# 📋 Spécification Métier — `calendrier-bookings-proprio`

> **Date :** 2026-05-15
> **Validée par :** utilisateur (oui)
> **Mode workflow :** `/feature full`

---

## 1. Contexte

Aujourd'hui, le proprio n'a pas de vue d'ensemble de l'occupation de toutes ses annonces ni de moyen de saisir une réservation manuelle (réservation hors plateforme — client direct ou démarcheur). Il doit ouvrir chaque annonce une par une pour voir son calendrier, et ne peut pas tracer les revenus reçus en dehors de la plateforme Asfar.

## 2. Objectif

Livrer un **écran unique "Calendrier & bookings"** accessible depuis le dashboard qui :
- Affiche la disponibilité de **toutes** ses annonces (chips horizontales pour switcher)
- Donne les **stats du mois** : taux d'occupation, jours libres, manque à gagner potentiel
- Présente un **conseil intelligent** chiffré (manque à gagner court-terme) pour pousser à débloquer
- Liste les **réservations du mois** sur l'annonce sélectionnée
- Permet de **bloquer une période** (maintenance, perso) ou **créer une réservation manuelle** (client direct ou démarcheur partenaire)

## 3. Acteurs

- **Propriétaire** — acteur principal et unique de cette feature.
- **Backend** — fournit les calendriers (déjà en place), reçoit les créations de réservation manuelle (endpoint existant `ReservationService.updateManualReservation` référencé, create à vérifier).

## 4. Règles Métier

### 4.1 Stats du mois affichées par annonce

| Stat | Calcul | Tone visuel |
|---|---|---|
| **Occupé** | Nombre de jours du mois avec une réservation (confirmée OU en attente) | Danger (rouge) |
| **Libre** | Jours du mois - Occupé - Bloqué par proprio | Success (vert) |
| **Manque à gagner** | (Libre + Bloqué) × prix/nuit | Accent (or) |

> Le « Manque à gagner » inclut volontairement les jours bloqués — objectif : inciter à débloquer ce qui peut l'être (maintenance prolongée, perso non urgent).

### 4.2 Conseil intelligent (TipSuggestionEngine V1)

Scope : **la semaine en cours** (lundi → dimanche).

Algorithme V1 :
1. Compter `joursLibres` dans la semaine (= libres + bloqués proprio)
2. Si `joursLibres >= 4` → afficher le conseil, sinon masqué
3. Suggestion = « En augmentant l'ouverture de N jours cette semaine, vous pourriez gagner jusqu'à X FCFA supplémentaires. » avec :
   - `N = min(joursLibres, 4)`
   - `X = N × prix/nuit × tauxOccupationMoyen` (fallback 70% si pas d'historique)

### 4.3 Réservations du mois (liste)

Filtre : `statut != ANNULE` ET `(dateDebut OR dateFin) dans le mois en cours` ET `appartementId == annonceSélectionnée`.

Tri : par `dateDebut` croissante.

Affichage par row : date verticale (DD-DD MMM) + nom client + source (Direct/Démarcheur Nom) + badge statut (Confirmé/En cours) + montant.

### 4.4 Bouton « + Bloquer / Réserver » (ActionSheet 2 options)

- **Option A** « Bloquer une période » → date range picker modal. Au valide → dispatch sur `AvailabilityBloc`. Pas de wizard.
- **Option B** « Réserver pour un client direct » → wizard 3 étapes.

### 4.5 Wizard création réservation manuelle (3 étapes)

**Étape 1 — Dates** : calendrier date range picker. Plage en conflit (réservation ou blocage) = visuellement rouge non-tappable.

**Étape 2 — Infos client + source + paiement** :
- Nom complet (obligatoire)
- Téléphone (obligatoire, format CI)
- **Source (2 radios)** : `Client direct` (pas de commission) | `Démarcheur partenaire` (commission 10% — picker démarcheur activé si choisi)
- Mode de paiement (4 chips, obligatoire) : `Espèces` | `Wave` | `Orange Money` | `Virement` — tracking proprio uniquement, n'affecte pas la commission Asfar
- Récap : `N nuits × prix/n = Total client` + `Vous recevez = Total - commission éventuelle`

> Pas de source « Via Asfar » : une résa manuelle est par définition hors plateforme.

**Étape 3 — Confirmation** : SuccessCircle vert + référence générée `ASF-XXXXXX` + récap + CTA « Retour au calendrier ». Dispatch sur `ReservationBloc` + `CalendarPlageBloc.refresh`.

### 4.6 Card dashboard « Calendrier & bookings »

Sous-titre dynamique : « **N séjours en cours** » où en cours = réservations actives aujourd'hui (`dateDebut <= today < dateFin` ET `statut == CONFIRMÉ`).

Tap → ouvre l'écran avec 1ère annonce sélectionnée par défaut.

### 4.7 Validation wizard

- Plage avec chevauchement → invalide.
- Date d'arrivée passée → **autorisée** (résa rétroactive possible).
- Nom et téléphone obligatoires non vides.
- Mode paiement obligatoire.
- Si source = Démarcheur → un démarcheur doit être sélectionné.

## 5. Cas d'Usage Principal — Création réservation manuelle

1. Proprio ouvre dashboard → tape sur card « Calendrier & bookings »
2. Écran s'ouvre sur 1re annonce (`Loft moderne — Plateau`) avec calendrier de novembre
3. Tape sur « + Bloquer / Réserver » → ActionSheet → choisit « Réserver pour un client direct »
4. **Step 1** : sélectionne 16-17 nov
5. **Step 2** : saisit nom, téléphone, choisit Client direct, choisit Wave
6. Récap : `1 nuit × 68k = 68 000`, « Vous recevez 68 000 »
7. Valide → **Step 3** : confirmation « Réservation enregistrée — réf ASF-H8R2X »
8. Tape « Retour au calendrier » → 16-17 nov marqué occupé, liste réservations incrémentée.

## 6. Cas Alternatifs / Limites

- **Double booking côté serveur** : step 3 affiche erreur avec retour step 1.
- **Annonce sans prix** : stats « Manque à gagner » = `—` ; wizard création bloque.
- **Pas d'annonce du tout** : empty state avec CTA « Créer ma première annonce ».
- **Conseil indisponible** (`joursLibres < 4`) : pas de bandeau (graceful).
- **Source démarcheur sans partenariat actif** : picker empty state + lien `PartenariatScreen`.

## 7. Contraintes

- **Réutilisation prioritaire** des BLoCs/widgets/utils existants (cf. brief orchestrateur).
- **Coordination backend** : confirmer endpoint create-reservation-manuelle. Documenter dans `BACKEND_NOTES_RESERVATION_DETAIL.md` si gap.
- **Conformité** aux 10 règles Flutter + SOLID + mémoire `feedback_container_alignment_bug.md`.
- **Pas de filtre nouveau côté locataire** — feature 100% proprio.

## 8. Critères d'Acceptation

- [ ] Card dashboard avec bon comptage « N séjours en cours » (actifs aujourd'hui).
- [ ] Écran calendrier affiche 1re annonce par défaut + chips scrollables.
- [ ] Stats du mois correctes (Occupé/Libre/Manque à gagner inclut blocages proprio).
- [ ] Bandeau Conseil affiché uniquement si joursLibres >= 4 dans la semaine.
- [ ] Liste « Réservations du mois » filtre correctement.
- [ ] Bouton ActionSheet 2 options.
- [ ] « Bloquer une période » dispatch sur AvailabilityBloc sans wizard.
- [ ] « Réserver client direct » ouvre le wizard 3 étapes.
- [ ] Wizard step 1 empêche sélection plage en conflit.
- [ ] Wizard step 2 a 2 sources (pas Via Asfar).
- [ ] Wizard step 2 demande mode paiement parmi 4 chips.
- [ ] Wizard step 3 affiche référence générée + retour calendrier.
- [ ] Date d'arrivée passée autorisée.
- [ ] Calendrier mis à jour automatiquement après création.
