# 🗂 Backlog Backend — Changements attendus par le mobile

> **Date :** 2026-06-11 · **MàJ 2026-06-11 (soir)** : items 4, 5, 6, 14, 16
> livrés côté backend (audit 99/100, non commités) — voir les ✅ et la section
> « Écarts de contrat annoncés » en fin de document.
> **Sources :** `BACKEND_NOTES_*.md`, `TODO_CALENDAR_LOCATAIRE.md`,
> `CHANGELOG_SESSION_2026-06-02.md`, fiches d'audit `.ai-outputs/audit/`.
> **Hors scope (dev local) :** la migration HTTPS/WSS (SEC-01) est volontairement
> mise de côté tant qu'on est en environnement de dev. Le mobile est déjà prêt
> (`kUseTls`, défaut `true`, surchargeable via `USE_TLS=false` dans le `.env`).
> À réactiver avant toute mise en production.

---

## Conventions de contrat (rappel)

Tout endpoint Asfar respecte ces conventions — chaque item ci-dessous les suppose :

| Convention | Règle |
|---|---|
| **Préfixe `auth/...`** | Route **publique**, pas de Bearer (login, refresh…) |
| **Préfixe `api/...`** | Route **privée**, Bearer obligatoire |
| **Enveloppe réponse** | `{ "body": <données>, "message": "..." }` — le mobile déballe via `tryExtractBody` |
| **Devise** | FCFA / XOF implicite, aucun champ `currency` |
| **Statuts réservation** | `EN_ATTENTE / CONFIRMER / PAYER / FINALISER / REFUSEE / ANULLE / TERMINEE` (⚠️ typo `ANULLE` historique, conservée) |
| **Dates** | ISO-8601 (`2026-06-12T00:00:00Z` ou local sans offset selon endpoint existant) |

---

## 🔴 P0 — Sécurité / bloquants fonctionnels

### 1. Contrôle d'accès `GET /api/user/reservations/{reference}` — 🔍 à vérifier

La page détail réservation s'ouvre désormais par **deep-link push** avec la seule
référence. L'endpoint existe (V9.2) mais le contrôle d'accès doit être confirmé :

- ✅ Autorisé : le **locataire** lié à la résa
- ✅ Autorisé : le **propriétaire** de l'appartement
- ✅ Autorisé : le **démarcheur source** (`ReservationDemarcheur.demarcheur`)
- ❌ Tout autre utilisateur authentifié → **403**

Côté mobile : rien à faire (un 403/404 affiche déjà « Réservation introuvable »).

### 2. Calendrier locataire — DTO réduit + endpoint dédié — ⚠️ bloque un chantier mobile

Le `CalendarPlageDTO` actuel expose `reference`, `montant`, `demarcheurNom`,
`demarcheurTelephone`, `montantCommission` — acceptable pour proprio/démarcheur,
**interdit pour un locataire**. Le chantier « calendrier locataire » (anti-intersection
dans le tunnel de réservation) est **gelé côté mobile** tant que cet endpoint n'existe pas.

**Endpoint attendu :**
```
GET /api/locataire/appartements/{id}/calendar?debut=...&fin=...
Authorization: Bearer <locataire>
```

**Réponse attendue** (`LocataireCalendarPlageDTO` — uniquement 3 champs par plage) :
```json
{
  "body": {
    "appartId": 12,
    "plages": [
      { "debut": "2026-06-10T12:00", "fin": "2026-06-15T11:00", "statut": "OCCUPE" }
    ]
  }
}
```

Pas de `type` (masque l'origine démarcheur/locataire), pas de référence, pas de
montants, pas d'infos démarcheur. Contrat explicite plutôt que filtrage in-place
(audit plus simple).

### 3. Révocation JWT au logout (SEC-05)

**Endpoint attendu :**
```
POST /auth/logout
Authorization: Bearer <token à révoquer>
→ 200 (toujours, même si token déjà invalide)
```

Le serveur blackliste le JWT (ou invalide la session) jusqu'à son expiration
naturelle. Côté mobile, `logout()` appellera l'endpoint en fire-and-forget avant
le nettoyage local (le logout local ne doit jamais échouer hors-ligne).

**Phase 2 (souhaitable) :** couple access token court (~15 min) / refresh token
long + endpoint de refresh — le mobile ajoutera alors le rafraîchissement
automatique sur 401 dans l'intercepteur Dio.

---

## 🟠 P1 — Le mobile est livré et attend le serveur

### 4. Pagination `page`/`size` sur les listes (PERF-02) — ✅ LIVRÉ BACKEND (2026-06-11)

> Livré rétrocompatible : `?page=&size=` optionnels sur `apparts`,
> `reservations` et `reservations/owner`. Avec params → enveloppe
> `{body, message, totalElements, hasNext}` (`ResponseServeurPagine`) ;
> sans params → réponse historique identique.

Le mobile (lot praticité/fluidité) envoie **déjà** `page` et `size` sur les listes
appartements et réservations, et tolère un backend non paginé (déduplication par
id, arrêt si 0 nouvel élément). Le gain réel n'arrive qu'avec le serveur.

**Attendu** sur les endpoints listes (Spring Data `Pageable` le donne quasi gratuitement) :
```
GET auth/appartement/apparts?page=0&size=20
GET /api/user/reservations/...?page=0&size=20
```

**Réponse attendue :**
```json
{
  "body": [ ... ],
  "totalElements": 134,
  "hasNext": true
}
```

> V2 scalabilité (> 500 annonces) : passer en cursor-based
> (`?cursor=<id>&limit=20` → `{ "body": [...], "nextCursor": 42, "hasMore": true }`),
> plus stable sous concurrence. Non requis tant que la base reste petite.

### 5. `typeLocation` enum strict + migration des annonces existantes — ✅ LIVRÉ BACKEND (2026-06-11)

> Enum strict + validation (400), chambres forcées, migration legacy idempotente
> au démarrage (`TypeLocationMigrationLoader`), filtres carte/recherche tolérants
> aux valeurs inconnues.

Le mobile envoie **déjà** l'enum strict à la création/édition. Attendu côté serveur :

**Validation `POST`/`PUT` Appartement :**

| `typeLocation` | `nbChambres` |
|---|---|
| `STUDIO` | forcé à 1 |
| `DEUX_PIECES` | forcé à 1 |
| `TROIS_PIECES` | forcé à 2 |
| `QUATRE_PIECES` | forcé à 3 |
| `CINQ_PLUS` | saisie libre, **refuser si < 4** (400) |

Toute autre valeur → **400**.

**Migration one-shot SQL** des annonces legacy (strings libres « Studio », « 2 pièces »,
« Appartement entier »…) : scripts complets prêts à l'emploi dans
`BACKEND_NOTES_ANNONCE.md` §0 (matching par string puis dérivation depuis `nbChambres`).

Compat : le mobile lit les deux formats (enum strict **et** legacy), le déploiement
peut être désynchronisé sans casse.

### 6. Édition d'une réservation manuelle — nouvel endpoint — ✅ LIVRÉ BACKEND (2026-06-11)

> ⚠️ **Écart de contrat** : les résas manuelles naissent en `FINALISER` côté
> backend → statuts éditables = `{EN_ATTENTE, CONFIRMER, FINALISER}` (et non
> `{EN_ATTENTE, CONFIRMER}` comme spécifié ci-dessous). 409 si non éditable ou
> séjour terminé ; anti-chevauchement excluant la résa éditée ; référence et
> statut inchangés. **Le mobile doit aligner `ReservationActionsResolver`.**

Le bouton « Modifier » mobile est câblé sur `ReservationService.updateManualReservation`.

**Endpoint attendu :**
```
PUT /api/user/reservations/owner/manual/{reference}
Authorization: Bearer <proprio>
```
```json
{
  "appartId": 12,
  "debut": "2026-06-12T00:00:00Z",
  "dure": 3,
  "clientNom": "Aya Konan",
  "clientTelephone": "+22507991234",
  "clientEmail": "aya@example.com",
  "montant": 65000
}
```

**Règles :**
- Seul le propriétaire de l'appartement lié peut éditer.
- `409 Conflict` si `statut ∉ {EN_ATTENTE, CONFIRMER}` — body `{"message": "Édition impossible pour ce statut"}`.
- `400` si dates incohérentes (fin ≤ début).
- La `reference` reste **inchangée** (préserve cards chat + notifications).
- Retourne la `Reservation` mise à jour (enveloppe `{body, message}` habituelle).

### 7. Mise hors ligne d'une annonce par le proprio — nouvel endpoint

L'action mobile (lot modération annonces) est livrée. Sur le modèle de
`resoumettre` qui existe déjà :

```
POST api/proprietaire/appartement/{id}/mettre-hors-ligne
Authorization: Bearer <proprio>
```

Transition `EN_LIGNE → HORS_LIGNE`, action de modération `RETRAIT_PROPRIO`
(nouvelle valeur — ne pas réutiliser `DESACTIVE`, réservé à l'admin avec motif
+ notification). Machine à états confirmée : `EN_LIGNE ↔ HORS_LIGNE` (proprio),
`REFUSER → EN_COURS` (resoumission).

### 8. Règle de visibilité unifiée des annonces — 🚨 décision métier requise

Trois dimensions coexistent sans règle claire : `brouillon: bool?`,
`isVisible: bool?`, `status` (enum). Questions ouvertes : un appart
`EN_MAINTENANCE` ou `OCCUPE` reste-t-il visible (réservation bloquée) ?
Quelle différence entre `brouillon` et `isVisible == false` ?

**Recommandation :** une règle unique côté serveur, appliquée au feed locataire :
```java
public boolean isPublic(Appartement a) {
  return !a.isBrouillon() && a.isVisible() && a.getStatus() != INACTIF;
}
```
Le serveur n'envoie au locataire que les annonces qui passent le filtre ; les 3
champs deviennent purement informatifs côté mobile.

### 9. Sérialisation polymorphique `ReservationDemarcheur` — 🔍 à valider runtime

L'héritage `@Inheritance(TABLE_PER_CLASS)` existe ; vérifier que le JSON sérialisé
inclut bien la discrimination et les champs de la sous-classe (sinon `@JsonTypeInfo`
ou serializer custom) :

```json
{
  "id": 102,
  "type": "DEMARCHEUR",
  "prix": 25000,
  "demarcheur": { "id": 12, "nom": "Diallo", "prenom": "K.", "telephone": "+22507991234" },
  "montantCommission": 2500
}
```

Le modèle Flutter polymorphe (`ReservationPlateforme` / `ReservationManuelle` /
`ReservationDemarcheur`, switch sur `json['type']`) est livré.

---

## 🟡 P2 — Améliorations attendues à moyen terme

### 10. Réservation manuelle — persister le payload étendu

Le mobile envoie **déjà** 3 champs supplémentaires sur la création
(`POST /api/user/reservations/owner/manual/create`), ignorés silencieusement
aujourd'hui :

```json
{
  "appartId": 12,
  "debut": "2026-11-16T00:00:00.000",
  "dure": 1,
  "clientNom": "Madame Touré",
  "clientTelephone": "+225 07 12 34 56",
  "montant": 68000,
  "source": "CLIENT_DIRECT",
  "moyenPaiement": "WAVE",
  "demarcheurId": null
}
```

**Attendu :**
1. Accepter les 3 champs sans erreur (déjà le cas si parser tolérant).
2. Persister `source` (`CLIENT_DIRECT` | `DEMARCHEUR_PARTENAIRE`) et
   `moyenPaiement` (`ESPECES` | `WAVE` | `OM` | `VIREMENT`) sur `ReservationManuelle`.
3. Si `source == DEMARCHEUR_PARTENAIRE` : persister `demarcheur_id` (FK),
   calculer `montantCommission` côté serveur (taux ~10 % **à confirmer métier**),
   et trancher si la résa sort en `type = DEMARCHEUR` ou `MANUELLE`.
4. Si `CLIENT_DIRECT` : aucune commission, comportement actuel.

### 11. Référentiel villes/communes — tester avant de créer

**Étape 1 — test (5 min)** : vérifier si l'arbre complet est déjà nested :
```bash
curl -i "http://<host>/api/lieux/pays/CI" -H "Authorization: Bearer <token>"
```
Si la réponse contient `regions[].villes[].communes[]` → **rien à créer**
(Stratégie A, le mobile consomme `PaysBloc` existant).

**Étape 2 — sinon (Stratégie B, ~3h)** : créer tables + seed + endpoints :
```
GET /api/lieux/villes?withCommunes=true
GET /api/lieux/villes/{villeId}/communes
```
```json
[
  {
    "id": 1, "nom": "Abidjan", "code": "ABJ", "ville": true,
    "region": { "id": 1, "nom": "Lagunes" },
    "communes": [
      { "id": 11, "nom": "Plateau", "commune": true },
      { "id": 12, "nom": "Cocody", "commune": true }
    ]
  }
]
```
Seed initial : 10 villes CI + 18 communes (12 Abidjan, 4 Yamoussoukro, 2 fallback) —
listes complètes dans `BACKEND_NOTES_VILLES_COMMUNES.md` §2.
Cache conseillé : `Cache-Control: max-age=86400` + `ETag`.
Aujourd'hui ces listes sont **hardcodées** dans le wizard mobile (étape Localisation).

### 12. Backfill `status` des annonces legacy

Les annonces créées avant la modération ont `status: null` (badge « ANNONCE »
côté mobile). Décision attendue : **backfill** du `status` en base (vrai fix)
ou le mobile assume durablement le fallback `visible` → En ligne/Hors ligne.

### 13. Canal WebSocket `/user/queue/updates` — confirmer l'activation

La synchro temps réel mobile est branchée dessus (patch statut APPARTEMENT,
reload ciblé DOCUMENT/PARTENARIAT/RESERVATION). Enveloppe attendue :
`{ eventId, entityType, action }`. À confirmer actif côté serveur pour valider
les tests de bout en bout.

### 14. Exposer `proprio` (hôte) pour le démarcheur — ✅ LIVRÉ BACKEND (2026-06-11)

> Option B retenue : le JSON d'`Appartement` contient `"proprio": {id, nom,
> prenom, telephone}` (DTO réduit). Chemin mobile : `r.appart.proprio` —
> à brancher dans `referral_detail_screen`.

`Reservation.proprio` est commenté côté backend → toujours `null` côté mobile
(écran détail partenariat démarcheur). Options :
- A. `proprio: Proprietaire` directement sur `Reservation`
- **B. (recommandé)** `proprio` sur `Appartement` → chemin `r.appart.proprio` (relation 1:N naturelle)
- C. Endpoint dédié `GET /api/appartement/{id}/proprio`

### 15. Documenter la sémantique de `Reservation.frais`

Si `frais` = commission plateforme Asfar : le mobile supprimera ses constantes
codées en dur (`0.06` / `0.08`, alors que `GET /auth/config/commission` retourne
**5 %**) et utilisera directement `sum(r.frais)`. Sinon, documenter ce que c'est.

### 16. Champ `note` sur le DTO Appartement — ✅ LIVRÉ BACKEND (2026-06-11)

> `note` stocké (tri SQL possible), arrondi 1 décimale, recalculé à chaque
> sauvegarde d'un commentaire (AVG). NB : aucun endpoint ne crée encore de
> commentaires d'appartement — hook prêt pour quand le flux existera.

```json
{ "id": 12, "titre": "Loft Plateau", "note": 4.6 }
```
Moyenne des `commentaire.note`, calculée serveur (requête AVG, trigger ou listener).
Fallback mobile en place (moyenne des commentaires reçus), mais une note serveur
stable évite le recalcul à chaque rendu et **rend possible le tri par note**.

### 17. Dictionnaire de commodités normalisé

Aujourd'hui le wizard envoie des chaînes libres (`Commodite(nom: 'WiFi fibre')`)
→ doublons (« WiFi » / « Wifi » / « WIFI ») et références fragiles.

```
GET /api/commodites
→ [ { "id": 1, "nom": "WiFi", "iconCode": "wifi" }, { "id": 2, "nom": "Clim", "iconCode": "ac_unit" } ]
```
Le mobile basculera ensuite sur l'envoi par `id`. (Même logique applicable plus
tard aux « règles types » `appartementRules`.)

---

## 🟢 P3 — V2 / selon décision métier

### 18. Timestamps de transition sur `Reservation`

Pour dater la timeline d'historique (« Confirmée le 5 mai 2026 ») — aujourd'hui
reconstruite sans dates précises (seul `createdAt` existe) :

```java
// Tous nullable — posés par les méthodes de transition
private Instant confirmedAt;
private Instant paidAt;
private Instant finalizedAt;
private Instant terminatedAt;
private Instant refusedAt;
private Instant cancelledAt;
```
Aucune rupture mobile : les champs sont simplement parsés s'ils apparaissent.

### 19. `nbVoyageursMax` + `surfaceM2` sur Appartement

```json
{ "nbLits": 2, "nbChambres": 1, "nbDouches": 1, "nbVoyageursMax": 4, "surfaceM2": 65 }
```
Enrichit la fiche détail (capacité d'accueil + surface). Les 3 colonnes actuelles
(lits/chambres/sdb) restent honnêtes en attendant.

### 20. `fraisMenage` (optionnel, FCFA)

Seulement si le métier tranche pour des frais de ménage séparés du prix de base —
le placeholder UI a été retiré du wizard en attendant la décision.

---

## ✅ Déjà résolus côté backend (rien à faire — mémo)

| Sujet | Référence |
|---|---|
| Cards riches chat — Option C `[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}` / `[ASFAR_CARD:partenariat]{"id":12}` + `isSystem` | `BACKEND_NOTES_RICH_CARDS_V8.md` §10 |
| `GET /api/demande-partenariat/{id}` | brief 2026-05-11 |
| Obfuscation coordonnées carte (calcul + stabilité côté serveur) | `BACKEND_NOTES_MAP_V9_7B.md` §3 |
| `/real-location` réservé aux statuts `PAYER`/`FINALISER` | `BACKEND_NOTES_MAP_V9_7B.md` §1 |
| `geoLat`/`geoLongi` calculés par geocoding serveur | `BACKEND_NOTES_MAP_V9_7B.md` §8 |
| Devise FCFA implicite dans `/filtered` | `BACKEND_NOTES_MAP_V9_7B.md` §7 |
| Héritage `ReservationDemarcheur` (`demarcheur`, `montantCommission`) | `BACKEND_NOTES_FINANCES_PDF.md` §1 (reste la validation runtime, cf. P1 n°9) |
| `GET /auth/config/commission` → `{ "taux": 5.0 }` | `CHANGELOG_SESSION_2026-06-02.md` |
| Conversations mixtes Proprio↔Démarcheur | brief 2026-05-11 |

---

## ⚠️ Écarts de contrat annoncés par le backend (2026-06-11)

> ✅ **Répercutés côté mobile le 2026-06-11** (feature
> `alignement-contrat-reservations`, audit 98/100) : enum réduit à 5 statuts,
> matrice d'édition manuelle élargie à FINALISER, lecture de la clé `proprio`.

1. **Statuts réservation** : le backend ne connaît que
   `EN_ATTENTE / CONFIRMER / PAYER / FINALISER / ANULLE` — **`REFUSEE` et
   `TERMINEE` n'existent pas** côté serveur, alors que l'enum mobile
   `ReservationStatus` (`lib/model/reservation/reservation.dart`) les déclare.
2. **Résa manuelle** : naît en `FINALISER` (pas `CONFIRMER`) → statuts
   éditables `{EN_ATTENTE, CONFIRMER, FINALISER}` ; la matrice
   `ReservationActionsResolver` mobile doit inclure `FINALISER`, sinon le
   bouton « Modifier » n'apparaîtra jamais pour les manuelles.
3. **Dates normalisées serveur** : check-in 09:00, check-out 12:00 — le mobile
   ne doit pas s'étonner que les heures envoyées soient réécrites.

## 📋 Vue d'ensemble

| # | Changement | Type | Priorité |
|---|---|---|---|
| 1 | Contrôle d'accès `GET /api/user/reservations/{ref}` | Vérification | 🔴 P0 |
| 2 | `GET /api/locataire/appartements/{id}/calendar` (DTO réduit) | Nouvel endpoint | 🔴 P0 |
| 3 | `POST /auth/logout` (blacklist JWT) | Nouvel endpoint | 🔴 P0 |
| 4 | Pagination `page`/`size` + `totalElements`/`hasNext` | Évolution endpoints | ✅ Livré 11/06 |
| 5 | `typeLocation` enum strict + migration SQL | Validation + migration | ✅ Livré 11/06 |
| 6 | `PUT /owner/manual/{reference}` (édition résa manuelle) | Nouvel endpoint | ✅ Livré 11/06 (statuts ⚠️) |
| 7 | `POST .../mettre-hors-ligne` | Nouvel endpoint | 🟠 P1 |
| 8 | Règle de visibilité unifiée | Décision métier | 🟠 P1 |
| 9 | Sérialisation polymorphique `ReservationDemarcheur` | Vérification | 🟠 P1 |
| 10 | Persistance `source`/`moyenPaiement`/`demarcheurId` + commission | Évolution endpoint | 🟡 P2 |
| 11 | Référentiel villes/communes (tester puis créer si besoin) | Test puis endpoints | 🟡 P2 |
| 12 | Backfill `status` annonces legacy | Migration données | 🟡 P2 |
| 13 | Canal WS `/user/queue/updates` actif | Vérification | 🟡 P2 |
| 14 | Exposer `proprio` (via Appartement recommandé) | Évolution DTO | ✅ Livré 11/06 |
| 15 | Sémantique `Reservation.frais` | Documentation | 🟡 P2 |
| 16 | Champ `note` sur Appartement | Évolution DTO | ✅ Livré 11/06 |
| 17 | `GET /api/commodites` (dictionnaire) | Nouvel endpoint | 🟡 P2 |
| 18 | Timestamps de transition réservation | Évolution modèle | 🟢 P3 |
| 19 | `nbVoyageursMax` + `surfaceM2` | Évolution modèle | 🟢 P3 |
| 20 | `fraisMenage` | Décision métier | 🟢 P3 |
| — | HTTPS/WSS (SEC-01) | **Reporté — prod uniquement** | ⏸ |
