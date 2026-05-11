# 📋 Spécification Métier — V9.2 Intégration brief backend (cards système + map align)

> **Version :** 1.0
> **Date :** 2026-05-11
> **Status :** ✅ Validée

---

## 1. Contexte

Le backend Asfar a livré 2 features structurantes (2026-05-11) : (1) un système de **messages système** dans le chat qui émet automatiquement des cards riches lors de paiements de réservations ou d'acceptations de partenariats, (2) un alignement du contrat map (devise FCFA, calcul `geoLat/geoLongi` automatique côté serveur). Côté Flutter, le mapper actuel détecte les préfixes `[ASFAR_CARD:*]` mais ne construit pas les payloads (retourne `null`) — la chaîne est donc dormante. V9.2 active cette chaîne et fait les ajustements de naming/cleanup associés.

## 2. Objectif

Intégrer le brief backend en **4 lots** cohérents :
- **L1** — Cards système opérationnelles avec fetch détail lazy
- **L2** — Cleanup AddressReq (ne plus envoyer `geoLat/geoLongi`)
- **L3** — Vérification conversations mixtes proprio↔démarcheur
- **L4** — Docs synchronisées

À la fin de V9.2, quand le backend émettra `[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}` ou `[ASFAR_CARD:partenariat]{"id":12}`, Flutter affichera et fera fonctionner les cards de bout en bout.

## 3. Acteurs

- **Locataire** — reçoit une card "Réservation confirmée" après paiement (depuis sa conversation avec le proprio). Tap → push `LocataireDetailScreen` (focus appart).
- **Propriétaire** — reçoit une card "Demande de partenariat acceptée" depuis sa conversation avec un démarcheur. Tap → push `PartenariatDetailScreen` (nouveau, transverse).
- **Démarcheur** — reçoit une card "Demande de partenariat acceptée" depuis sa conversation avec un proprio. Tap → push **même** `PartenariatDetailScreen` (transverse).
- **Backend Asfar** — émet les messages système, fournit les 2 endpoints de fetch détail.

## 4. Règles Métier

### R1 — Renommage `referral` → `partenariat` (cascade)
- Préfixe détecté : `[ASFAR_CARD:partenariat]` (plus `referral`)
- Modèle UI-only `AcceptedReferralCardPayload` → `AcceptedPartenariatCardPayload`
- Widget `accepted_referral_message_card.dart` → `accepted_partenariat_message_card.dart`
- Endpoint fetch : `GET /api/demande-partenariat/{id}` (pas `/referral`)
- L'écran `ReferralDetailScreen` V9.6 (démarcheur uniquement) reste **inchangé** — c'est un autre flow

### R2 — Champ `isSystem` du modèle `ChatMessage`
- Ajouter `bool? isSystem;` au modèle Hive `ChatMessage` (`@HiveField(9)`)
- `fromJson` lit `json['isSystem']`, valeur par défaut `false`
- Le mapper `ChatMessageToUiMapper` détecte la card via `isSystem == true` ET le préfixe `[ASFAR_CARD:type]`

### R3 — Tolérance `clientId/clientNom/clientType` null
- Pour les messages système, le backend renvoie ces 3 champs à `null`
- `ChatMessage.fromJson` doit accepter sans crasher (probablement déjà OK avec `?` nullable)
- Côté UI thread, ne pas afficher `expediteur` pour les messages système (la card est centrée/full width)

### R4 — Parsing payload mapper
- Pour `MessageKind.reservationCard` : extraire `{"ref":"ASF-XXX"}` du contenu → `ReservationCardPayload(reference: "ASF-XXX")` (string ref, pas int id)
- Pour `MessageKind.acceptedPartenariatCard` (renommé) : extraire `{"id":12}` → `AcceptedPartenariatCardPayload(demandeId: 12)` (int id)

### R5 — Lazy fetch dans les widgets card
- `ReservationMessageCard` devient `StatefulWidget` : `initState` appelle `ReservationService.getByReference(reference)` → reçoit `Reservation` complète → swap content
- `AcceptedPartenariatMessageCard` devient `StatefulWidget` : `initState` appelle `PartenariatProprioService.getDemandeById(id)` → reçoit `DemandePartenariatProprio` complet → swap content
- Pendant le fetch : **skeleton subtil** (zones gris `bgElev2` sur titre/dates), structure card visible
- Si fetch échoue (réseau, 403, 404) : afficher la card avec **contenu basique** du payload (juste `ref` ou `id`) + chip discret "Indisponible"

### R6 — Push au tap
- Tap `ReservationMessageCard` (avec détail fetché) → `pushScreen(LocataireDetailScreen(listing: AppartementToListingMapper.mapOne(reservation.appart)))` (V9.7c)
- Tap `AcceptedPartenariatMessageCard` (avec détail fetché) → `pushScreen(PartenariatDetailScreen(demande: detail))` — **nouvel écran transverse à créer**

### R7 — Conversation mixte Proprio↔Démarcheur
- Le mapper `ConversationToPreviewMapper._otherParty` doit gérer le cas où `c.locataire` peut être un `Demarcheur` (sous-classe de `Client`)
- Vérifier `_roleFor` : actuellement retourne `tenant`/`host` par défaut, ajouter cas `demarcheur` si applicable
- `MessagingThreadScreen` : pas d'assomption rigide sur le type d'interlocuteur

### R8 — Cleanup `AddressReq` côté création appartement
- `Address.toJson()` continue d'envoyer `lat/longi` (coords téléphone) — backend en a besoin
- **Ne plus envoyer** `geoLat/geoLongi` (backend les calcule par geocoding auto)
- Approche : créer une méthode `Address.toAddressReqJson()` qui exclut `geoLat/geoLongi`, OU modifier `AppartementBackendMapper.toCreatePayload` pour stripper ces 2 champs après sérialisation

### R9 — Idempotence UI
- Si la même card arrive 2× (rejeu serveur), le backend garantit l'idempotence : pas de doublon côté DB
- Côté Flutter, pas de dedup spécifique — on fait confiance au backend

### R10 — Compteur unread
- Les messages système comptent dans le badge "messages non lus" comme les messages texte
- Comportement déjà géré par `Conversation.unreadCount` côté Bloc — aucun changement requis

## 5. Cas d'Usage Principal

**Cas A — Locataire paie sa résa**
1. Locataire paie depuis l'écran réservation → backend traite `POST /api/user/reservations/{ref}/pay`
2. Backend émet automatiquement un message système dans la conversation locataire↔proprio : `[ASFAR_CARD:reservation]{"ref":"ASF-7K2N9"}`
3. La conversation se rafraîchit (polling ou ouverture manuelle) → Flutter récupère le message avec `isSystem: true`
4. Mapper construit `ChatMessage(kind: reservationCard, reservation: ReservationCardPayload(reference: "ASF-7K2N9"))`
5. `ThreadMessageItem` rend `ReservationMessageCard` qui démarre `initState` → `getByReference("ASF-7K2N9")`
6. Skeleton affiché ~500ms, puis swap avec titre appart + dates + code
7. Locataire tap → push `LocataireDetailScreen` (focus appart)

**Cas B — Démarcheur reçoit acceptation partenariat**
1. Proprio accepte la demande depuis son écran partenariats → backend traite `POST /api/proprietaire/partenariat/demandes/{id}/accepter`
2. Backend émet message système dans conv proprio↔démarcheur : `[ASFAR_CARD:partenariat]{"id":12}`
3. Démarcheur ouvre l'app → conversation → voit la card avec skeleton
4. Mapper parse `{"id":12}` → `AcceptedPartenariatCardPayload(demandeId: 12)`
5. Card lazy fetch via `getDemandeById(12)` → reçoit nom proprio, statut, dates
6. Démarcheur tap → push `PartenariatDetailScreen(demande: detail)` (nouveau, transverse)

## 6. Cas Alternatifs / Limites

- **Fetch lazy échoue (réseau down)** : card visible avec contenu basique (`Réservation ASF-XXX` ou `Partenariat #12`) + chip "Indisponible" discret. Tap fallback ?
  - Pour la card réservation : tap désactivé (pas de listing à push)
  - Pour la card partenariat : tap désactivé (PartenariatDetailScreen exige le payload complet)
- **403 sur fetch** (user n'a pas accès) : même comportement que 404 — contenu basique
- **Message système isolé hors conv connue** : le backend garantit que la conv existe (créée auto si besoin)
- **Préfixe inconnu** (ex: futur `[ASFAR_CARD:newType]`) : fallback `MessageKind.text` (le contenu brut s'affiche en bubble texte) — extensibilité préservée
- **Cards comptent dans unread** : déjà géré par le backend, badge auto

## 7. Contraintes

- **Cohérence rénommage** : 100% des références `referral` côté code Flutter pour les cards passent à `partenariat`. L'écran `ReferralDetailScreen` démarcheur V9.6 reste (autre flow). Le dossier `partenariats/` existant reste.
- **Sécurité** : Flutter fait confiance au backend pour `isSystem` (pas de vérif locale du préfixe pour confirmer)
- **Performance** : chaque card fait 1 RTT au mount. Si une conv contient 10 cards, 10 fetches parallèles. Acceptable MVP — cache HTTP standard.
- **Modèle Reservation** : doit avoir `getByReference(String reference)` — à vérifier/ajouter
- **Pas de WebSocket temps réel** : polling REST suffisant pour V9.2. Refresh manuel après actions clés (paiement validé) recommandé.

## 8. Critères d'Acceptation

- [ ] `ChatMessage.isSystem` ajouté + parse JSON
- [ ] `ChatMessageToUiMapper` détecte cards via `isSystem` ET parse les payloads (plus de `null`)
- [ ] `[ASFAR_CARD:partenariat]` détecté à la place de `referral`
- [ ] `AcceptedReferralCardPayload` renommé `AcceptedPartenariatCardPayload` (+ widget + imports cascade)
- [ ] `ReservationMessageCard` `StatefulWidget` avec lazy fetch + skeleton + fallback erreur
- [ ] `AcceptedPartenariatMessageCard` `StatefulWidget` avec lazy fetch + skeleton + fallback erreur
- [ ] `ReservationService.getByReference(reference)` créé/branché
- [ ] `PartenariatProprioService.getDemandeById(id)` créé/branché
- [ ] Nouveau `PartenariatDetailScreen` transverse créé
- [ ] `MessagingThreadScreen._onReservationTap` push `LocataireDetailScreen`
- [ ] `MessagingThreadScreen._onPartenariatTap` push `PartenariatDetailScreen`
- [ ] Tolérance `clientId/clientNom/clientType` null gérée
- [ ] Conv mixte Proprio↔Démarcheur audit fait + ajustement mapper si besoin
- [ ] `AddressReq` ne contient plus `geoLat/geoLongi`
- [ ] Docs : `BACKEND_NOTES_RICH_CARDS_V8.md` update Option C confirmée + `BACKEND_NOTES_MAP_V9_7B.md` update (devise, geoLat backend) + `RECONSTRUCTION_UI_ASFAR.md` cards V8 ✅
- [ ] `flutter analyze` : 0 nouvelle erreur
