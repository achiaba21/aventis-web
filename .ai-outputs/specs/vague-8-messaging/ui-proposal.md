# 🎨 Proposition UI/UX — Vague 8 Messaging

> **Auteur :** Agent UI/UX (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Résolu par fidélité proto + 1 décision utilisateur sur la zone ouverte
> **Source primaire :** `~/Downloads/Asfar Prototype.html` + `.ai-outputs/prototype-extract/extras.jsx` (lignes 77-288)
> **Consigne utilisateur :** « rester fidèle au proto, signaler les zones où le proto ne tranche pas »

---

## 1. Démarche

L'archi V8 (`architecture.md`) a tranché l'essentiel via les décisions BA (mocks, cards spéciales, search local). Cette proposition documente :
1. Les **zones tranchées par lecture directe du proto** (CTAs non câblés, valeurs visuelles exactes)
2. **1 zone ouverte remontée à l'utilisateur** sur les threads par conversation — décision actée

## 2. Zones tranchées par fidélité proto

### 2.1 MessagingList — TopNav et listrow

**Source proto** : `extras.jsx::MessagingList` (lignes 100-153)

| Élément | Décision |
|---|---|
| **TopNav title** | « Messages » |
| **TopNav right** | `IconBoutton(edit, size 16)` — pas d'onClick proto → SnackBar « Nouvelle conversation bientôt » |
| **Search input** | Visuel statique dans le proto (span « Rechercher » avec icon search 18). Décision BA : TextField fonctionnel + filtre local. Reproduit le visuel proto + ajoute logique. |
| **Listrow alignement** | `alignItems: flex-start` (l'avatar est aligné en haut, pas centré) |
| **Avatar** | 46×46 (réutilise `UserAvatar` V1) |
| **Row 1 : nom** | fontSize 14, fontWeight 600, ellipsis si trop long |
| **Row 1 : shield certifié** | Icon shield 12px accent, à côté du nom (gap 6) |
| **Row 1 : heure** | fontSize 11 t-small, alignée à droite |
| **Row 2 : badge rôle** | fontSize 9, tons proto : `Démarcheur=info`, `Asfar=neutral`, `Hôte/Locataire/Client=accent` (proto:126-127) |
| **Row 2 : sub** | fontSize 11 t-small, prefixe `· ` |
| **Row 3 : last message** | fontSize 13. **`text` color si unread > 0** sinon `text3`. fontWeight 500 si unread > 0 sinon 400 |
| **Row 3 : badge unread** | Cercle 18×18 radius 99, fond `accent`, texte `onAccent` (#1A1206), fontSize 11 fontWeight 700, marginLeft 8. Caché si `unread === 0`. |
| **Padding listrow** | Géré par classe `listrow` (assumé 14×16 cohérent V5-V7) |

### 2.2 MessagingThread — header custom

**Source proto** : `extras.jsx::MessagingThread` (lignes 192-214)

| Élément | Décision |
|---|---|
| **Padding top** | 56 (status bar safe area) |
| **Border-bottom** | 1 line |
| **Padding intérieur** | `10px 14px 14px` |
| **Layout** | Row gap 12 alignItems center : back + avatar 38 + bloc texte expand + phone |
| **Avatar** | 38×38 (`UserAvatar` V1) |
| **Nom** | fontSize 14 fontWeight 600 + shield 12 accent si certified |
| **Sub** | fontSize 11 t-small marginTop 1 (juste sous le nom) |
| **Bouton phone** | `IconBoutton(phone, size 16)` — pas d'onClick proto → SnackBar « Appel disponible prochainement » |

### 2.3 MessagingThread — séparateur date et zone messages

**Source proto** : `extras.jsx` (lignes 216-267)

| Élément | Décision |
|---|---|
| **Padding zone scroll** | `20px 18px 0` |
| **Layout messages** | `flex column` gap 8 |
| **Séparateur date** | « Aujourd'hui » centré, fontSize 11 t-small, marginBottom 12. **Hardcodé** (proto ne gère pas les dates) |
| **Wrapper message** | Row avec `justifyContent: flex-end` si `me`, sinon `flex-start`. marginBottom 4. |

### 2.4 Bubble texte (me / them)

**Source proto** : `extras.jsx` (lignes 247-263)

| Élément | Décision |
|---|---|
| **maxWidth** | 78% de l'écran |
| **Padding** | 10×14 |
| **Background** | `accent` si `me`, `bgElev2` sinon |
| **Color** | `onAccent` (#1A1206) si `me`, `text` sinon |
| **borderRadius** | 18 sur 3 coins, **6 sur le coin opposé à la queue** : bottomRight 6 si `me`, bottomLeft 6 sinon |
| **fontSize** | 14, lineHeight 1.4 |
| **Heure (en bas)** | fontSize 10, opacity 0.6, alignée à droite si `me`, à gauche sinon, marginTop 4 |

### 2.5 Card Réservation (kind == 'card' dans le proto)

**Source proto** : `extras.jsx` (lignes 224-232)

| Élément | Décision |
|---|---|
| **Container** | `card` style (= `bgElev1 line lg`) maxWidth 82% padding 12 |
| **Layout** | Row gap 10 |
| **ImgPh** | 56×56 radius 10, tone du listing |
| **Texte** | Column avec eyebrow `RÉSERVATION` 9px + titre 13 w600 + sub dates 11 small + bookingCode mono 11 w600 marginTop 2 |
| **Tap** | SnackBar « Détail réservation disponible prochainement » (renvoie vers `LocataireDetailScreen` V5 quand BLoCs branchés) |

### 2.6 Card Demande acceptée (kind == 'accept')

**Source proto** : `extras.jsx` (lignes 234-246)

| Élément | Décision |
|---|---|
| **Container** | `card` style maxWidth 82% padding 12, **fond `accentSoft`**, border `1 rgba(232,184,107,0.25)` (= `accent.withAlpha(0.25)`) |
| **Row 1** | gap 8 marginBottom 4 : icon check 16 accent strokeWidth 2.6 + label « Demande acceptée » 13 w700 accent |
| **Sub** | fontSize 11 t-small (référence + listing + dates) |
| **Commission** | mono 13 w700 marginTop 4 : `Commission: +${FcfaFormatter.full(commission)}` |
| **Tap** | SnackBar « Détail référence disponible prochainement » (renvoie vers `ReferralDetailScreen` V6 quand BLoCs branchés) |

### 2.7 Input bar (sticky bottom)

**Source proto** : `extras.jsx` (lignes 270-285)

| Élément | Décision |
|---|---|
| **Padding** | `10px 14px 30px` (le 30 bottom = safe area iOS) |
| **Border-top** | 1 line |
| **Background** | `rgba(10,10,11,0.92)` — peut s'envelopper dans `BlurContainer` V1 pour un effet blur cohérent (proto a un flat alpha mais Liquid Glass est l'identité Asfar) |
| **Layout** | Row gap 10 alignItems center |
| **Bouton plus** | `IconBoutton(plus, size 20)` — pas d'onClick proto → SnackBar « Pièce jointe disponible prochainement » |
| **Champ** | InputField V1 flex 1, padding 10×14, hint « Message… » fontSize 14 |
| **Bouton send** | Bouton rond 40×40 radius 99, background `accent`. Icon send 18 strokeWidth 2.2 color `onAccent`. **Désactivé si champ vide** (opacity 0.4 ou couleur muted, non tappable) |

---

## 3. Zone ouverte tranchée par utilisateur

### 3.1 Threads par conversation vs par rôle

**Question :** le proto utilise `data[role]` (extras.jsx:190) — un seul thread par rôle, partagé par toutes les conversations. UX incohérent (tap sur Service Asfar → voir Aminata K.).

**Décision utilisateur (2026-05-10) :** approche **dynamique** :

> « non c'est le même compte mais sous différentes interfaces tel que décrit au début, ça doit être dynamique et qu'on est aligné, il y a tous les services pour cela qui ont été faits »

**Application V8 :**

1. **3 threads riches** mockés fidèlement au proto pour les conversations principales :
   - **L1 (Aminata K., locataire)** : 5 messages dont 1 `reservationCard` (Loft Plateau, 12-15 nov, ASF-7K2N9)
   - **P1 (Rachid B., propriétaire)** : 4 messages texte
   - **D1 (Aminata K., démarcheur)** : 5 messages dont 1 `acceptedReferralCard` (REF-D8H3K, 13 500 FCFA)

2. **Threads génériques** pour les autres conversations (L2/L3, P2/P3/P4, D2/D3) : liste de messages vide, et le `MessagingThreadScreen` affiche un placeholder centré « Démarrez la conversation… » (small + text3).

3. **Header dynamique** : adapté à la `ConversationPreview` reçue en paramètre (nom, sub, certified de la conversation cliquée — pas du thread).

4. **TODO REBUILD documenté** dans `RECONSTRUCTION_UI_ASFAR.md` : « Branchement `ConversationBloc` réel pour V8 — les BLoCs et services existent déjà côté projet, à brancher en finition (vague post-V9) ».

## 4. Token / cohérence transverse

Aucun nouveau token couleur nécessaire. Tous les visuels du proto sont supportés par les tokens existants :
- `AppColors.accent` / `accentSoft` / `bgElev1` / `bgElev2` / `line` / `text` / `text2` / `text3` / `onAccent` / `info`
- `BadgeTone.info` (Démarcheur), `BadgeTone.neutral` (Asfar), `BadgeTone.accent` (Hôte/Locataire/Client)

## 5. Note `BadgeStatus` fontSize

Le proto force `fontSize: 9` sur les badges rôle de `MessagingList` (lignes 127). Notre atome `BadgeStatus` V1 utilise par défaut `fontSize: 11`. **Écart visuel mineur** (2px). Décision : conserver `BadgeStatus` tel quel sans paramètre `fontSize` custom — l'écart est imperceptible et préserve l'atome.

→ Si l'utilisateur préfère 9px exact, il faudra ajouter un paramètre `fontSize` à `BadgeStatus` (mais ça touche à un atome partagé V1, refacto transverse).

## 6. Composants à créer (récap)

Aucun ajout par rapport à l'archi validée § 5.

## 7. Composants à réutiliser

Aucun ajout par rapport à l'archi § 1.2.

## 8. Points actés en début Lot 1

- [x] **Threads** : 3 threads riches (L1/P1/D1) + threads vides pour les autres conversations + header dynamique
- [x] **Header thread** : `Container` border-bottom inline (pas `DynamicAppBar`) pour fidélité proto
- [x] **Input bar wrapper** : `BlurContainer` V1 pour cohérence Liquid Glass Asfar (proto a un flat alpha, on enrichit visuellement sans casser)
- [x] **Bouton send désactivé** : opacity 0.4 quand champ vide, non tappable
- [x] **Cards tap** : SnackBar stub avec mention « Détail bientôt » (TODO REBUILD branchement V5/V6 quand BLoCs réels)

## 9. TODO REBUILD à ajouter

| Fichier / Zone | Action future |
|---|---|
| `messaging_list_screen.dart` + `messaging_thread_screen.dart` | Brancher sur `ConversationBloc` existant (services déjà faits côté projet) — vague de finition post-V9 |
| Card Réservation tap | Push `LocataireDetailScreen` V5 avec listing réel quand BLoCs branchés |
| Card Demande acceptée tap | Push `ReferralDetailScreen` V6 avec référence réelle quand BLoCs branchés |
| Bouton phone header | Brancher sur `url_launcher` `tel:` quand téléphone réel disponible (V9) |
| Bouton plus input bar | Pièce jointe (image/file picker) — V9 |

---

## ✅ Validation UI/UX

- [x] Le proto a été lu directement comme source primaire (extras.jsx 77-288)
- [x] Aucune création de pattern UI/UX qui n'existe pas dans le proto (sauf `BlurContainer` sur input bar pour cohérence Asfar — écart mineur enrichissant)
- [x] La zone ouverte (threads par conversation) a été remontée explicitement à l'utilisateur et tranchée
- [x] Les CTAs non câblés du proto sont stubés en SnackBar avec mention de la cible future
- [x] BadgeStatus fontSize 9 vs 11 documenté comme écart mineur acceptable
- [x] Cohérence avec règle R5 du `RECONSTRUCTION_UI_ASFAR.md` (Layout 100% prototype + adaptation Asfar quand pas couvert)

**Statut :** proposition UI/UX validée → transmission à l'agent Flutter Dev pour implémentation.
