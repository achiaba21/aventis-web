# 🛰️ Notes Backend — Cards riches dans les messages V8

> **🟢 STATUT : ACTIVÉ V9.2 (2026-05-11)** — Option C (URI+ID minimaliste) **confirmée par le backend** et **livrée côté Flutter**. Voir §10 ci-dessous pour le récap d'activation. Le reste du document conserve le contexte historique de l'analyse V8.3.

> **Date initiale :** 2026-05-11
> **Contexte :** finalisation V8.3 — les `MessagingThreadScreen` côté Flutter savent rendre deux cards riches (`ReservationMessageCard` et `AcceptedReferralMessageCard` → renommé `AcceptedPartenariatMessageCard` en V9.2) qui doivent pouvoir être déclenchées par certains messages serveur. Aujourd'hui le mapper Flutter (`ChatMessageToUiMapper`) détecte le `MessageKind` via des **préfixes textuels** sur le champ `contenu`, mais le backend ne les émet jamais encore. Ce document propose 3 façons de transporter ces cards.

---

## 1. État actuel — modèle `ChatMessage`

Le modèle persistant Asfar (`lib/model/conversation/chat_message.dart`, Hive `typeId: 1`) :

```dart
class ChatMessage {
  int? id;
  User? expediteur;
  String? contenu;          // ← un seul champ de texte libre
  DateTime? createdAt;
  int? conversationId;      // alias serveur : seanceId
  bool? isRead;
  bool? isSending;
  bool? hasFailed;
  String? tempId;
}
```

JSON envoyé/reçu :
```json
{
  "id": 42,
  "client": { ... User ... },
  "contenu": "Salut, je viens de réserver !",
  "createdAt": "2026-05-11T08:30:00Z",
  "conversationId": 7,
  "seanceId": 7,
  "isRead": false
}
```

Le backend n'a **aucun champ structuré** pour transporter une réservation ou une référence acceptée. Tout doit transiter via `contenu` (string), ou via un changement de contrat.

---

## 2. Convention de détection côté Flutter (existante mais dormante)

Dans `lib/util/mapping/chat_message_to_ui.dart` :

```dart
static const _reservationPrefix = '[ASFAR_CARD:reservation]';
static const _referralPrefix    = '[ASFAR_CARD:referral]';

static MessageKind _detectKind(String contenu) {
  if (contenu.startsWith(_reservationPrefix)) return MessageKind.reservationCard;
  if (contenu.startsWith(_referralPrefix))    return MessageKind.acceptedReferralCard;
  return MessageKind.text;
}
```

Le mapper sait **détecter** les cards, mais ne peut pas **construire** le payload riche (`ReservationCardPayload`, `AcceptedReferralCardPayload`) car le contenu actuel ne porte pas les données nécessaires. Aujourd'hui le mapper retourne toujours `payload: null` → tous les messages sont rendus en bubble texte.

---

## 3. Trois options pour transporter une card

### 🔵 Option A — Préfixe + JSON inline dans `contenu`

**Principe** : le backend encode le payload complet en JSON inline derrière le préfixe.

**Format `contenu`** :
```
[ASFAR_CARD:reservation]{"id":12,"appartId":312,"title":"Studio Plateau","price":40000,"dates":"12-15 nov","bookingCode":"ASF-7K2N9","tone":1,"area":"Plateau","city":"Abidjan"}
```

Pour Demande acceptée :
```
[ASFAR_CARD:referral]{"id":"REF-D8H3K","clientName":"Aminata K.","clientPhone":"+22507991234","listing":{"id":"312","title":"Studio Plateau","price":40000,"area":"Plateau","city":"Abidjan","tone":1},"nights":3,"sentAt":"2026-05-10T14:32:00Z","status":"accepted","commission":13500}
```

**Côté Flutter** : `ChatMessageToUiMapper` parse `contenu.substring(prefix.length)` en JSON et construit le payload typé.

**Côté backend** : il suffit d'envoyer un message normal via `MessageService.send()` avec ce format dans `contenu`. Pas de modification du modèle, pas de migration Hive.

| Avantages | Inconvénients |
|---|---|
| ✅ Zéro modification du modèle backend | ❌ `contenu` n'est plus lisible humain ("[ASFAR_CARD:reservation]{...}") |
| ✅ Compatible WebSocket existant tel quel | ❌ Si une vieille version d'app reçoit ce message, elle l'affiche tel quel (texte brut illisible) |
| ✅ Aucune migration Hive (`typeId: 1` préservé) | ❌ Payload dupliqué : si la résa change (annulation, etc.), le message reste avec les anciennes données |
| ✅ Payload immédiatement consommable, pas d'appel API supplémentaire | ❌ Limite taille message (les contraintes BDD peuvent imposer une limite varchar) |

---

### 🟢 Option B — Champs typés supplémentaires sur `ChatMessage`

**Principe** : ajouter à l'entité backend des champs structurés.

**Schéma BDD étendu** :
```sql
ALTER TABLE chat_message ADD COLUMN message_type VARCHAR(32) DEFAULT 'TEXT';
ALTER TABLE chat_message ADD COLUMN payload_json TEXT;
```

`message_type` ∈ `{TEXT, RESERVATION_CARD, ACCEPTED_REFERRAL_CARD}` (enum sur le backend).

**JSON envoyé/reçu** :
```json
{
  "id": 42,
  "client": { ... },
  "contenu": "Je viens de réserver Studio Plateau",
  "messageType": "RESERVATION_CARD",
  "payloadJson": "{\"id\":12,\"appartId\":312,...}",
  "createdAt": "2026-05-11T08:30:00Z",
  "conversationId": 7
}
```

**Côté Flutter** :
- `ChatMessage.fromJson` lit les 2 nouveaux champs
- `ChatMessageToUiMapper._detectKind` switch sur `messageType` au lieu du préfixe
- `payloadJson` est parsé selon `messageType`
- `contenu` reste un **texte lisible** (preview affiché dans la liste des conversations)

| Avantages | Inconvénients |
|---|---|
| ✅ Séparation responsabilité claire (texte ↔ payload) | ❌ Migration BDD obligatoire |
| ✅ `contenu` reste lisible (compatibility ancienne app) | ❌ Modification modèle Hive → potentielle migration (incrément `typeId` ou ajout fields) |
| ✅ Backend peut filtrer/indexer par type | ❌ Changement contrat REST + WebSocket |
| ✅ `MessagingListScreen` peut afficher icône spéciale dans la conv liste (`messageType != 'TEXT'`) | ❌ Refonte serializer + tests |

---

### 🟡 Option C — Convention URI dans `contenu` + fetch on demand (Recommandé)

**Principe** : le `contenu` reste majoritairement texte, mais peut contenir une **URI custom** que le mapper Flutter détecte. Au tap, l'app fetch les données complètes via les services REST déjà existants.

**Format `contenu`** (3 variantes) :

Variante 1 — texte avec URI à la fin :
```
Je viens de réserver Studio Plateau · asfar://reservation/12
```

Variante 2 — URI seule (le message visuel sera la card spéciale, pas une bubble) :
```
asfar://reservation/12
```

Variante 3 — JSON minimal avec juste l'ID, comme Option A mais minimaliste :
```
[ASFAR_CARD:reservation]{"id":12}
```

**Côté Flutter** :
- Mapper détecte l'URI via regex sur `contenu`
- Au tap (ou au mount si on veut afficher la card directement) → appel `ReservationService.getById(12)` ou `ReferralService.getByCode("REF-D8H3K")` → reçoit le modèle métier complet → construit le payload typé
- Possibilité de cache Hive court terme pour éviter spam des fetches

**Côté backend** :
- `MessageService.send()` met l'URI dans `contenu`
- **Pré-requis** : endpoints `GET /api/booking/{id}` et `GET /api/referral/{code}` doivent retourner un DTO complet (probablement déjà le cas pour booking, à vérifier pour referral)

| Avantages | Inconvénients |
|---|---|
| ✅ **Source de vérité = service dédié, toujours frais** (si résa annulée, le fetch retourne le statut à jour) | ❌ Latence : 1 appel API supplémentaire au tap (ou au mount) |
| ✅ Pas de modification modèle backend (Option A "light") | ❌ Si offline, la card ne se construit pas (sauf cache) |
| ✅ `contenu` peut rester en partie lisible humain (variante 1) | ❌ Nécessite endpoints REST cohérents |
| ✅ Payload léger dans le message (juste un ID) | |
| ✅ Compatible avec une futur app version qui veut afficher plus de détails (refetch suffit) | |

---

## 4. Recommandation

**Option C** — variante 3 (`[ASFAR_CARD:reservation]{"id":12}` minimaliste) :

| Critère | Justification |
|---|---|
| **Effort backend minimal** | Pas de migration BDD, juste émettre le bon format dans `MessageService.send()` quand une résa est créée ou une demande acceptée |
| **Source de vérité unique** | La résa est dans `Booking` table — `ChatMessage` ne stocke qu'un pointeur, jamais désynchronisé |
| **Cohérence projet** | Le format `[ASFAR_CARD:type]{...}` est déjà détecté côté Flutter — juste le payload est plus léger |
| **Évolutif** | Demain on veut ajouter `version` dans la card → juste extend le DTO du service, pas du message |

### Flow concret côté backend Spring Boot

1. **Quand une résa est confirmée** (statut `CONFIRMER` → `PAYER`) :
   - Le proprio reçoit déjà une notification dans `ChatMessage`
   - Modifier la création du message : `contenu = "[ASFAR_CARD:reservation]{\"id\":" + booking.getId() + "}"`
   - Émettre via WebSocket comme aujourd'hui

2. **Quand un démarcheur reçoit une réponse "Acceptée"** :
   - `contenu = "[ASFAR_CARD:referral]{\"code\":\"" + referral.getCode() + "\"}"`

3. **Pour preview dans `MessagingListScreen`** :
   - Le backend peut soit dupliquer un résumé texte dans un champ adjacent (`lastMessagePreview`), soit Flutter affiche "📅 Réservation partagée" / "✅ Demande acceptée" basé sur le détection du préfixe

### Côté Flutter (changement requis)

`ChatMessageToUiMapper.mapOne` doit :
1. Détecter le préfixe (déjà fait)
2. Parser le `{"id": 12}` ou `{"code": "..."}` (minimal)
3. **Async fetch** via `ReservationService.getById(id)` / `ReferralService.getByCode(code)`
4. Construire le payload riche depuis le modèle métier complet
5. Le mapper devient async (`Future<ChatMessage>` au lieu de `ChatMessage`) OU on rend le fetch paresseux dans le widget card lui-même

**Pattern conseillé** : le mapper reste sync, retourne un `payload` avec juste l'ID. Le widget `ReservationMessageCard` devient `StatefulWidget` qui charge le détail au mount (comme `MapMarkerBottomSheet` V9.7b a fait pour la photo lazy). UX : skeleton ~200ms puis swap avec données complètes.

---

## 5. Endpoints backend pré-requis

| Endpoint | Statut actuel | Action |
|---|---|---|
| `GET /api/booking/{id}` | Probablement existe | Vérifier qu'il retourne le `Booking` complet (avec appart, dates, prix, code) |
| `GET /api/referral/{code}` | Inconnu | À créer si absent — DTO `ReferralPreview` complet |

---

## 6. Plan d'exécution proposé

### Phase backend (recommandé Option C)

| Étape | Effort | Description |
|---|---|---|
| B1 | 30 min | Vérifier `GET /api/booking/{id}` existe et retourne le DTO complet (avec `appartId`, `bookingCode`, dates, prix) |
| B2 | 1h | Créer `GET /api/referral/{code}` si absent — DTO avec `clientName`, `clientPhone`, `appartId`, `nights`, `sentAt`, `status`, `commission` |
| B3 | 30 min | Modifier `MessageService.sendBookingConfirmation()` (ou équivalent) pour émettre `contenu = "[ASFAR_CARD:reservation]{\"id\":X}"` |
| B4 | 30 min | Idem pour les notifications de demande acceptée → `"[ASFAR_CARD:referral]{\"code\":\"...\"}"` |
| B5 | 30 min | Tests Postman : envoyer un message via WebSocket avec ces formats, vérifier réception côté Flutter |

### Phase Flutter (à faire quand backend prêt)

| Étape | Effort | Description |
|---|---|---|
| F1 | 1h | Étendre `ChatMessageToUiMapper` pour parser `{"id": 12}` ou `{"code": "..."}` et créer le payload avec juste l'ID |
| F2 | 1h | Refondre `ReservationMessageCard` en `StatefulWidget` qui charge le détail au mount via `ReservationService.getById` (pattern V9.7b photo lazy) |
| F3 | 1h | Idem pour `AcceptedReferralMessageCard` avec `ReferralService.getByCode` |
| F4 | 30 min | Tests runtime |

---

## 7. Alternative si urgence — Option A immédiate

Si le backend ne peut pas créer les endpoints `/api/referral/{code}` rapidement, **Option A** (JSON inline) est implémentable en 1h backend :

```java
String payload = objectMapper.writeValueAsString(Map.of(
    "id", booking.getId(),
    "appartId", booking.getAppartement().getId(),
    "title", booking.getAppartement().getTitre(),
    "price", booking.getAppartement().getPrix(),
    "dates", formatDates(booking),
    "bookingCode", booking.getReference(),
    "tone", booking.getAppartement().getId() % 4 + 1,
    "area", booking.getAppartement().getAddress().getCommune().getNom(),
    "city", "..."
));
chatMessage.setContenu("[ASFAR_CARD:reservation]" + payload);
```

Côté Flutter : `ChatMessageToUiMapper` parse `contenu.substring("[ASFAR_CARD:reservation]".length)` en JSON et construit `ReservationCardPayload` directement, sans fetch supplémentaire.

→ **Migration vers Option C** plus tard quand le besoin de fraîcheur émerge.

---

## 8. Récap mémo

| Question | Réponse |
|---|---|
| Le modèle `ChatMessage` doit-il être modifié ? | Non si Option A ou C, oui si Option B |
| Format actuel du contenu reconnu côté Flutter ? | Préfixes `[ASFAR_CARD:reservation]` et `[ASFAR_CARD:referral]` |
| Mapper Flutter émet-il déjà les cards ? | Non — il détecte le `MessageKind` mais retourne `payload: null` car le backend n'émet pas encore |
| Endpoint `GET /api/booking/{id}` requis ? | Pour Option C — à vérifier qu'il existe et retourne le DTO complet |
| Endpoint `GET /api/referral/{code}` requis ? | Pour Option C — probablement à créer |
| Quelle option recommandée ? | **C minimaliste** (juste l'ID dans le message, fetch détail lazy côté Flutter — pattern V9.7b photo lazy déjà éprouvé) |
| Fallback si urgence ? | **A** (JSON inline complet) — implémentable en 1h backend, migration vers C plus tard |

---

## 9. Référence code (état V8.3 — avant activation V9.2)

- Modèle backend : `lib/model/conversation/chat_message.dart`
- Mapper détection : `lib/util/mapping/chat_message_to_ui.dart:51-59`
- Payloads UI-only : `lib/model/ui_only/reservation_card_payload.dart` · `lib/model/ui_only/accepted_referral_card_payload.dart`
- Widgets cards : `lib/screen/client/shared/inbox/widget/reservation_message_card.dart` · `accepted_referral_message_card.dart`
- Push détail : `lib/screen/client/shared/inbox/messaging_thread_screen.dart:99-115`
- Modèles de détail :
  - `Appartement` (push `LocataireDetailScreen(listing: payload.listing)`) — fonctionne déjà
  - `ReferralPreview` (push `ReferralDetailScreen(referral: payload.referral)`) — payload prêt à recevoir, mapper à enrichir

---

## 10. ✅ V9.2 — Activation effective (2026-05-11)

> **Décision actée** : le backend a livré le brief 2026-05-11 confirmant **Option C minimaliste** + alignement renommage `referral → partenariat`. Flutter a intégré le tout via la feature V9.2.

### 10.1 Préfixes finaux confirmés par le backend

| Card | Préfixe + payload | Sens du champ |
|---|---|---|
| **Réservation** | `[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}` | `ref` est une **string** = code court résa (ex. `ASF-7K2N9`), pas l'id numérique |
| **Partenariat acceptée** | `[ASFAR_CARD:partenariat]{"id":12}` | `id` est un **int** = id de `demande_partenariat`. **Renommé** depuis `referral` côté backend |

### 10.2 Endpoints concrets livrés

| Endpoint | Verbe | Statut | Réponse |
|---|---|---|---|
| `/api/user/reservations/{reference}` | GET | ✅ Existait, branché V9.2 | `Reservation` complet (avec `appart`, dates, prix, statut) |
| `/api/demande-partenariat/{id}` | GET | ✅ **Nouveau backend brief 2026-05-11** | `{id, statut, createdAt, repondueAt, demarcheur:{id,nom,telephone}, proprietaire:{id,nom,telephone}}` |

### 10.3 Champ `isSystem` ajouté au modèle

- Backend envoie `isSystem: true` pour les messages système (cards) et `clientId/clientNom/clientType = null`
- Flutter : ajout `@HiveField(9) bool? isSystem` au modèle `ChatMessage` (typeId 1 **non modifié** — boxes Hive existantes restent compatibles car field nullable)
- Mapper utilise désormais `isSystem` **ET** présence du préfixe pour détecter le kind card

### 10.4 Renommage `referral` → `partenariat` côté Flutter

Cascade complète V9.2 :
- `_referralPrefix` → `_partenariatPrefix` (valeur `[ASFAR_CARD:partenariat]`)
- `AcceptedReferralCardPayload` → `AcceptedPartenariatCardPayload` (`String referralCode` → `int demandeId`)
- `accepted_referral_message_card.dart` → `accepted_partenariat_message_card.dart`
- `MessageKind.acceptedReferralCard` → `MessageKind.acceptedPartenariatCard`
- L'écran démarcheur `ReferralDetailScreen` (autre flow V9.6) reste inchangé

### 10.5 Pattern card lazy fetch (StatefulWidget)

```dart
class ReservationMessageCard extends StatefulWidget {
  final ReservationCardPayload payload; // {reference: "ASF-7K2N9"}
  final void Function(Reservation? loaded)? onTap;
  ...
}

class _ReservationMessageCardState extends State<ReservationMessageCard> {
  Reservation? _loaded;
  bool _isLoading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load(); // ReservationService().getByReference(payload.reference)
  }
  ...
}
```

Le widget affiche :
- **Loading** : skeleton 3 zones gris bgElev2 statiques (`SystemCardSkeletonRows`)
- **Loaded** : titre appart + dates + code mono accent or
- **Error** : titre fallback (`"Réservation ASF-XXX"`) + chip `"Indisponible"` text3 muted (`SystemCardUnavailableChip`)

### 10.6 Conversations Proprio↔Démarcheur supportées

Le backend supporte désormais des conv mixtes. Côté Flutter, `ConversationToPreviewMapper._roleFor` a été élargi pour gérer `ConversationRole.demarcheur` (proprio voit démarcheur).

### 10.7 Idempotence + cards comptent dans badge unread

- Backend garantit idempotence (pas de doublons cards)
- Cards systèmes comptent dans `unreadCount` comme messages normaux
- **Pas de WebSocket temps réel** : polling REST suffit (V9.2). WebSocket hors scope, tracker V10.

### 10.8 Référence code V9.2 (état actuel)

- Modèle : `lib/model/conversation/chat_message.dart:isSystem` (HiveField 9, nullable)
- Mapper : `lib/util/mapping/chat_message_to_ui.dart` (parsing JSON via `jsonDecode`, try/catch, fallback `MessageKind.text`)
- Payloads UI-only : `lib/model/ui_only/reservation_card_payload.dart` (refonte minimal `{reference}`) · `lib/model/ui_only/accepted_partenariat_card_payload.dart` (`{demandeId}`)
- Service nouveau : `lib/service/model/partenariat/partenariat_service.dart` (singleton, `getDemandeById(int)`)
- Service étendu : `lib/service/model/booking/reservation_service.dart` (+ `getByReference(String)`)
- Cards : `lib/screen/client/shared/inbox/widget/reservation_message_card.dart` · `accepted_partenariat_message_card.dart`
- Atomes partagés : `lib/screen/client/shared/inbox/widget/system_card_atoms.dart` (3 widgets DRY)
- Écran détail partenariat (nouveau, transverse proprio + démarcheur) : `lib/screen/client/shared/partenariats/partenariat_detail_screen.dart`
- Handlers push : `lib/screen/client/shared/inbox/messaging_thread_screen.dart` (`_onReservationTap`, `_onPartenariatTap`)
- Conv mixte : `lib/util/mapping/conversation_to_preview.dart:_roleFor` élargi

### 10.9 Doc complète V9.2

→ `.ai-outputs/docs/v9-2-cards-systeme-map-align.html`
