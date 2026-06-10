# Journal des actions — Session 2026-06-01 / 2026-06-02

Récapitulatif des modifications réalisées (modération annonces, filtres, commission
démarcheur, fallback commission plateforme, KPI occupation, synchro temps réel).

Statut global : `flutter analyze` = **0 erreur** (48 issues préexistantes) · `flutter test` = **246/246**.
⚠️ Tout est **local, non commité** au moment d'écrire ce fichier.

---

## 1. Modération des annonces (proprio) — statut + actions

### 1.1 Statuts (Lot 1)
- **`lib/model/enumeration/appartement_status.dart`** : enum aligné backend
  `EN_COURS / EN_LIGNE / HORS_LIGNE / REFUSER` (avant : `DISPONIBLE/OCCUPE/EN_MAINTENANCE/INACTIF`
  qui parsait `status` à `null` partout). `fromString` tolérant (casse + espaces),
  `// ignore_for_file: constant_identifier_names` (noms imposés par `status.name`).
- **`lib/util/calc/appartement_status_display.dart`** : libellés + tons de badge
  (EN_COURS=warn « En validation », EN_LIGNE=success « En ligne »,
  HORS_LIGNE=neutral « Hors ligne », REFUSER=danger « Refusée ») + `eyebrowLabel`.
- **`listing_full_card_hero.dart`** + **`proprio_listing_row.dart`** : badge **dynamique**
  via `appart.status` (avant : `● Actif` codé en dur).

### 1.2 Actions de modération (Lot 2)
Machine à états backend confirmée : `EN_LIGNE↔HORS_LIGNE` (proprio), `REFUSER→EN_COURS`
(resoumettre), refus/désactivation = admin. Le **motif** de refus n'est pas exposé au proprio.
- **`appartement_service.dart`** : `mettreHorsLigne(id)` / `remettreEnLigne(id)` / `resoumettre(id)`
  (POST body vide, `api/proprietaire/appartement/{id}/...`).
- **`appartement_repository.dart`** : 3 méthodes correspondantes (réutilisent `_persistAndReturn` → maj cache).
- **`appartement_bloc.dart`** (+ `_event.dart`) : events `MettreHorsLigneAppartement` /
  `RemettreEnLigneAppartement` / `ResoumetreAppartement` + handler partagé `_changeStatus`
  (succès → liste rafraîchie + message ; erreur → message backend relayé).
- **`widget/listing_moderation_actions.dart`** *(nouveau)* : boutons conditionnels selon statut
  (Mettre hors ligne / Remettre en ligne / Resoumettre / « en attente ») + message refus générique.
- **`listing_edit_screen.dart`** : widget d'actions branché dans l'entête + `BlocConsumer`
  (snackbar succès/erreur) + dialog de confirmation avant chaque action.

### 1.3 Bug bloquant « toutes les annonces disparaissent » (§6)
- **`lib/util/response/response_mapper.dart`** : `mapResponseAuto` rendu **résilient** — un item
  qui échoue au mapping est ignoré + loggué au lieu de faire échouer toute la liste.
- **`lib/model/residence/appart.dart`** : `DateTime.parse` → `DateTime.tryParse` (createdAt/updatedAt) ;
  parsing du statut rendu **multi-clés** (`status`/`statut`/`etat`/`etats`).

### 1.4 Bug « tout affiche ANNONCE » (statut null)
- Cause : **cache Hive périmé** (statuts sérialisés `null` du temps de l'ancien enum), servi sans refresh.
- **`listings_screen.dart`** : `initState` force `RefreshProprietaireAppartements` si la liste n'est
  pas vide (réécrit le cache avec les vrais statuts).

### Tests
- `test/model/enumeration/appartement_status_test.dart`, `test/util/calc/appartement_status_display_test.dart`,
  `test/util/response/response_mapper_test.dart`.

---

## 2. Filtres « Mes annonces » (proprio)

- Bug : `_filter` mémorisé mais **jamais appliqué** + libellés placeholders (compteurs `(0)`).
- **`lib/util/calc/listing_status_filter.dart`** *(nouveau)* : `ListingFilter` (Tout / En ligne /
  En validation / Hors ligne / Refusée) + `count` / `apply` / `label` / `fromLabel`.
- **`listings_screen.dart`** : filtre typé, chips + compteurs **réels**, liste filtrée, état vide « aucun résultat ».
- Test : `test/util/calc/listing_status_filter_test.dart`.

---

## 3. Commission du démarcheur — éditable

Backend : `montantCommission` = **montant libre FCFA par réservation**, proposé par le démarcheur,
validé par le proprio (0 autorisé, négatif rejeté). Aucun calcul auto serveur.
- **`demarcheur_appart_detail_screen.dart`** : `_commissionCtrl` + getters `_suggestedCommission` /
  `_commission` (saisie), pré-remplissage à **10 %** à la sélection des dates, envoi de la valeur saisie.
- **`widget/booking_form_section.dart`** : champ **« COMMISSION (FCFA) » éditable** + suggestion +
  bandeau récap (à la place du bandeau figé « 10 % »).
- Commentaires corrigés : `reservation_demarcheur.dart` (montant libre, pas « 12 % auto ») et
  `demarcheur_stats_calculator.dart` (`ReferralCommissionHelper.rate` = **suggestion** par défaut).

---

## 4. Commission plateforme Asfar — fallback hors-ligne

Backend : `GET /auth/config/commission` → `{ "taux": 5.0 }`. Le fallback codé en dur était **8 %** (faux).
- **`commission_service.dart`** : **cache** du dernier taux connu (app settings Hive) à chaque succès +
  `cachedTaux()`.
- **`commission_cubit.dart`** : repli sur **le dernier taux connu** au lieu de la constante.
  Chaîne de repli : API fraîche → dernier taux caché → `0.08` (ultime recours, jamais-connecté).

---

## 5. KPI dashboard proprio

- **`lib/util/calc/kpi_aggregator.dart`** : **occupation** = jours occupés ÷ (annonces **EN_LIGNE**
  × jours du mois) — avant : toutes les annonces gonflaient la capacité. Le numérateur ne compte
  que les réservations d'annonces en ligne.
- Convention des deltas expliquée : `+100 %` = « parti de zéro » (mois précédent à 0) ;
  `+0 %` = identique au mois précédent ; delta de la note **non calculé** (codé `0`).

---

## 6. Synchro temps réel — canal `/user/queue/updates`

Nouveau canal ciblé par utilisateur (en plus de `/user/queue/notifications` et `/topic/actions`).
- **`websocket_state.dart`** : `RealtimeAction` parse l'enveloppe `eventId` / `entityType` / `action`
  (+ getter `isUserUpdate`). Canal legacy `type` inchangé.
- **`websocket_service.dart`** : `_subscribeToUserUpdates()` → `/user/queue/updates` (réutilise
  `_handleActionMessage` → `actionStream`).
- **`realtime_action_handler.dart`** : `_handleUserUpdate` route selon `entityType` :
  - `APPARTEMENT` → `AppartementBloc.AppartementStatusPushed(id, nouveauStatus)` = **patch en place**.
  - `DOCUMENT` (KYC) → `DocumentCubit.load()`.
  - `PARTENARIAT` → `LoadDemandesRecues` (CREATED) / `LoadDemandesEnvoyees` (STATUS_CHANGED).
  - `RESERVATION` → `ReservationBloc.RefreshReservations()`.
- **`appartement_bloc.dart`** (+ `_event.dart`) : event `AppartementStatusPushed` + handler patch
  (no-op si l'annonce n'est pas dans la liste courante).

Note : APPARTEMENT = patch fin ; DOCUMENT/PARTENARIAT/RESERVATION = rechargement ciblé (v1).
Pré-requis test : le canal doit être actif côté backend.

---

## ⚠️ Diagnostics temporaires à RETIRER

- **`kpi_aggregator.dart`** : log `[KpiAggregator] courant=… réservations=X (prév Y)` (guard `_lastDiagSig`)
  — ajouté pour élucider le « 1 réservation / +0 % ». À retirer une fois la valeur analysée.

---

## ⏳ Décisions en attente

1. **Annonces legacy à `status: null`** (badge « ANNONCE ») : backend backfill du `status`
   (vrai fix) **ou** fallback mobile `visible` → En ligne/Hors ligne ?
2. **KPI « 1 réservation / +0 % »** : coller la ligne de log `[KpiAggregator] …` pour confirmer
   `resCurrent` vs `resPrev`.
3. **Commission plateforme** : aligner ou non l'ultime constante `0.08` → `0.05`.
4. **Synchro temps réel** : patch fin (au lieu de reload) pour DOCUMENT/PARTENARIAT/RESERVATION ?
5. **Commit** : regrouper en un commit unique ou plusieurs commits thématiques, puis push.
