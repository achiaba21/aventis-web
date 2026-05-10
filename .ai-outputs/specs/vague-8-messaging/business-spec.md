# 📋 Spécification Métier — Vague 8 Messaging

> **Auteur :** Business Analyst (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Validé par l'utilisateur
> **Parent :** `.ai-outputs/specs/refonte-design-asfar/business-spec.md` (cadre global)

---

## 1. Contexte

La reconstruction UI Asfar Premium a livré les Vagues 1-7. Les 3 Shells (Locataire V5, Démarcheur V6, Propriétaire V7) ont actuellement un `_MessagesPlaceholder` sur l'onglet Messages — un trou béant dans l'UX visible immédiatement par tous les utilisateurs.

La Vague 8 reconstruit la **messagerie transverse** fidèlement au prototype HTML (`extras.jsx::MessagingList` + `extras.jsx::MessagingThread`), **partagée entre les 3 rôles**, débloquant ainsi l'onglet Messages des 3 Shells. **Avec V8 livrée, les écrans du proto sont 100% reconstruits.**

## 2. Objectif

1. Implémenter `MessagingListScreen` (liste des conversations) **adaptative au rôle** de l'utilisateur connecté
2. Implémenter `MessagingThreadScreen` (chat 1-to-1) avec bubbles bidirectionnelles + cards spéciales (Réservation, Demande acceptée)
3. Brancher l'onglet Messages des 3 Shells (LocataireShell, DemarcheurShell, ProprioShell) sur `MessagingListScreen`

## 3. Acteurs

- **Locataire** — discute avec ses hôtes (= propriétaires) + service Asfar
- **Propriétaire** — discute avec ses locataires + démarcheurs partenaires
- **Démarcheur** — discute avec hôtes (propriétaires) qu'il référence + clients qu'il envoie

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **MessagingList par rôle** | Le contenu de la liste s'adapte au `user.type` actif : locataire voit hôtes, propriétaire voit locataires + démarcheurs, démarcheur voit hôtes + clients (cf. mocks proto extras.jsx:80-97) |
| RM2 | **Badges de rôle** | Chaque conversation affiche un badge texte du rôle de l'interlocuteur : `Hôte` / `Locataire` / `Démarcheur` / `Asfar` / `Client` |
| RM3 | **Badge unread** | Cercle accent or 18px avec compteur (1, 2, 3…) si `unread > 0`. Caché sinon |
| RM4 | **Icon shield certifié** | Icône bouclier accent à côté du nom si `certified == true` (proto applique aux hôtes superhost) |
| RM5 | **Sub adaptatif** | Sous-titre = listing concerné OU référence (ex: `REF-D8H3K · acceptée` côté démarcheur, `Loft Plateau · 12-15 nov` côté proprio) |
| RM6 | **Heure** | Format proto : `14:32` aujourd'hui, `Hier`, `12 oct` au-delà |
| RM7 | **Search input** | Input texte en haut de la liste — filtre local sur la liste mockée (recherche par `who` ou `sub`) |
| RM8 | **Thread bubbles** | `me` = fond accent or + texte `#1A1206` (onAccent) / `them` = fond `bgElev2` + texte `text`. Max-width 78%, radius 18px avec coin opposé à 6px (queue), heure 10px en dessous |
| RM9 | **Card spéciale Réservation** | Apparaît dans le thread : img listing 56px + eyebrow `RÉSERVATION` + titre + dates + code mono. Mock 1× par thread proprio/locataire applicable |
| RM10 | **Card spéciale Demande acceptée** | Apparaît dans le thread démarcheur : fond `accentSoft` + check + libellé + commission accent or |
| RM11 | **Input bar thread** | Bouton plus + champ texte « Message… » + bouton rond accent or send. Tap envoyer = ajout message `me` à la liste locale via `setState` (mock local, pas de persistance) |
| RM12 | **Header thread custom** | Back + avatar 38px + nom + shield si certifié + sub (rôle · listing) + bouton phone (SnackBar stub) |
| RM13 | **Onglet Messages branché** | Les 3 Shells utilisent désormais `MessagingListScreen` au lieu de `_MessagesPlaceholder`. Le screen lit le rôle de l'utilisateur courant pour afficher le bon mock |
| RM14 | **Tokens uniquement** | `AppColors.*`, `AppRadii.*`, `AppTextStyles.*` — pas de couleur/size en dur |
| RM15 | **Mocks** | Cohérence V5-V7 : pas de branchement BLoC réel. Les conversations sont en dur dans `SampleConversations.byRole` |

## 5. Cas d'Usage Principal

**Préconditions :** utilisateur connecté avec un rôle valide.

**Scénario nominal :**
1. Utilisateur tap onglet Messages dans son Shell
2. `MessagingListScreen` s'affiche avec mocks adaptés au rôle (3-4 conversations)
3. Utilisateur tape dans la search bar → filtre la liste localement
4. Utilisateur tap sur une conversation → `MessagingThreadScreen` push
5. Utilisateur voit le thread avec bubbles me/them + cards spéciales (si applicables)
6. Utilisateur saisit un message dans l'input bar et tape send
7. Le message apparaît dans la liste locale en bas du thread (mock local via `setState`)
8. Utilisateur tap back → retour à `MessagingListScreen`

**Cas multi-rôle :**
9. Si l'utilisateur switche de rôle (V6 Role Switcher), le nouveau Shell affiche le `MessagingListScreen` avec **les mocks du nouveau rôle** (locataire/proprio/démarcheur)

**Postconditions :**
- Onglet Messages fonctionnel sur les 3 Shells
- Avec V8 livrée, les 18 écrans du proto + 4 transverses sont reconstruits
- 0 erreur `flutter analyze`

## 6. Cas Alternatifs / Limites

| Cas | Comportement |
|---|---|
| CA1 | Search bar avec terme qui ne match aucune conversation | Liste vide. Pas d'empty state custom V8 (cohérence V6/V7 — empty states reportés post-V9) |
| CA2 | Tap sur button phone du header thread | SnackBar « Appel disponible prochainement » |
| CA3 | Tap sur button plus de l'input bar | SnackBar « Pièce jointe disponible prochainement » |
| CA4 | Message vide envoyé (champ blanc) | Bouton send désactivé (couleur muted, pas tappable) |
| CA5 | Card Réservation/Demande acceptée tap | SnackBar « Détail disponible prochainement » (renvoie vers Detail logement V5 ou ReferralDetail V6 dans une vague de finition) |
| CA6 | Switch de rôle pendant qu'un thread est ouvert | `pushAndRemoveAll` du `RoleHomeRouter` reset le stack — le thread est fermé, l'utilisateur arrive sur le nouveau Shell |

## 7. Gestion des Erreurs

| Erreur | Comportement |
|---|---|
| E1 | Mock incohérent (conversation pointe sur listing inexistant) | Fallback gracieux (ImgPh tone par défaut) — pas de crash |
| E2 | `user.type` inconnu (cas par défaut) | Mock locataire par défaut (`convosByRole[role] ?? convosByRole.locataire`) |
| E3 | Thread ouvert avec 0 messages | Affiche un état vide simple « Démarrez la conversation… » — éviter écran blanc |

## 8. Contraintes

- **Performance :** rendu fluide même avec 50+ messages dans un thread (`ListView.builder`)
- **Accessibilité :** contrastes WCAG AA, surtout les bubbles `them` sur `bgElev2`
- **Plateformes :** iOS 13+, Android 10+
- **10 règles Flutter du projet** : NON NÉGOCIABLES
- **Réutilisation maximale** des Vagues 1-7 (`UserAvatar`, `BadgeStatus`, `BlurContainer`, `DynamicAppBar`, `ImgPh`, `IconBoutton`, `InputField`, `ListingPreview`, `SampleListings`, etc.)
- **SOLID nouveau code** : nouveaux widgets respectent la séparation rôles

## 9. Critères d'Acceptation

- [ ] **CA-1.** `MessagingListScreen` lit `user.type` et affiche les mocks adaptés (locataire/proprio/démarcheur)
- [ ] **CA-2.** Search bar filtre localement la liste via `setState`
- [ ] **CA-3.** Conversations affichent : avatar 46px + who + badge rôle + sub + last message tronqué + heure + badge unread (si > 0) + shield si certifié
- [ ] **CA-4.** Tap conversation → `pushScreen(MessagingThreadScreen)` avec les paramètres de la conversation
- [ ] **CA-5.** `MessagingThreadScreen` header custom : back + avatar 38 + nom + shield + sub + bouton phone
- [ ] **CA-6.** Bubbles me/them avec styles fidèles au proto (max-width 78%, radius 18 avec queue 6, heure 10px)
- [ ] **CA-7.** Card Réservation visible dans au moins 1 thread mock (img listing 56 + eyebrow + dates + code mono)
- [ ] **CA-8.** Card Demande acceptée visible dans au moins 1 thread démarcheur mock (accentSoft + check + commission)
- [ ] **CA-9.** Input bar : plus + champ + send rond accent or
- [ ] **CA-10.** Tap send avec champ non vide ajoute le message à la liste locale (`setState`), bouton désactivé si champ vide
- [ ] **CA-11.** Tap phone / plus / cards spéciales = SnackBar stub
- [ ] **CA-12.** `LocataireShell.pages[3]`, `DemarcheurShell.pages[3]`, `ProprioShell.pages[3]` utilisent désormais `MessagingListScreen` (suppression des `_MessagesPlaceholder` privés des 3 Shells)
- [ ] **CA-13.** `flutter analyze` 0 nouvelle erreur (legacy 41 issues inchangées)
- [ ] **CA-14.** Score audit ≥ 60
- [ ] **CA-15.** `RECONSTRUCTION_UI_ASFAR.md` Vague 8 cochée (8.1 + 8.2) + journal mis à jour
- [ ] **CA-16.** Documentation HTML `vague-8-messaging.html` générée et indexée

## 10. Hors Périmètre

- ❌ **Notifications** (F6) → reporté à V9 hors-proto
- ❌ **Receipt PDF preview** (F8) → reporté à V9 hors-proto
- ❌ Branchement BLoC réel (`ConversationBloc` existant V5 mais pas branché) → vague de finition
- ❌ WebSocket / messages temps réel → vague de finition
- ❌ Persistance des messages envoyés (mock local seulement)
- ❌ Pièce jointe (image, fichier) — SnackBar stub
- ❌ Appel audio/vidéo — SnackBar stub
- ❌ Indicateur de lecture / typing — non dans proto

---

## 11. Décisions actées (questions BA)

| Q | Décision |
|---|---|
| Q1 — Scope V8 | **Messaging uniquement** (MessagingList + MessagingThread + branchement onglet Messages). Notifications → V9, Receipt PDF → V9 |
| Q2 — Cards spéciales thread | **Oui, fidèles au proto** — Card Réservation (img + dates + code) + Card Demande acceptée (accentSoft + check + commission) |
| Q3 — Input bar send | **Mock local** : `setState` ajoute le message à la liste locale. Champ vide = bouton send désactivé. Pas de persistance |

---

## 12. Inventaire des livrables Vague 8

### Écrans nouveaux (2)
| # | Écran | Fichier cible | Source proto |
|---|---|---|---|
| 8.1 | MessagingList | `lib/screen/client/shared/inbox/messaging_list_screen.dart` | `extras.jsx::MessagingList` |
| 8.2 | MessagingThread | `lib/screen/client/shared/inbox/messaging_thread_screen.dart` | `extras.jsx::MessagingThread` |

### Refactor (3)
| # | Action | Fichier |
|---|---|---|
| R1 | Brancher onglet Messages | `lib/screen/client/locataire/locataire_shell.dart` (remplace `_MessagesPlaceholder` par `MessagingListScreen`) |
| R2 | Brancher onglet Messages | `lib/screen/client/demarcheur/demarcheur_shell.dart` |
| R3 | Brancher onglet Messages | `lib/screen/client/proprio/proprio_shell.dart` |

### Mocks (1)
| # | Mock | Fichier |
|---|---|---|
| M1 | `SampleConversations` (3 listes : locataire, proprio, démarcheur) + `SampleThreads` (1-2 threads par conversation pour démontrer bubbles + cards spéciales) | `lib/screen/client/shared/inbox/sample/sample_conversations.dart` + `sample_threads.dart` |

### Modèles UI-only (3-4)
| # | Modèle | Description |
|---|---|---|
| M1 | `ConversationPreview` | id, who, sub, lastMessage, time, unread, role (enum), certified, listing? |
| M2 | `ChatMessage` | id, sender (me/them), text, time, type (text/reservationCard/acceptedCard) |
| M3 | `ReservationCardPayload` | listing ref + dates + bookingCode |
| M4 | `AcceptedReferralCardPayload` | label + commission + référence (pour démarcheur) |
| M5 | enum `ConversationRole` | host, tenant, demarcheur, asfar, client |

---

## ✅ Validation BA

- [x] Objectif clair (3 axes : MessagingList adaptatif + MessagingThread avec cards + branchement Shells)
- [x] Règles métier listées (RM1-RM15)
- [x] Cas d'usage nominal + multi-rôle décrit
- [x] Cas alternatifs/limites identifiés (CA1-CA6)
- [x] Erreurs identifiées (E1-E3)
- [x] Critères d'acceptation définis (CA-1 à CA-16)
- [x] Hors périmètre clarifié (Notifications + Receipt PDF reportés à V9)
- [x] Inventaire des livrables explicite (2 écrans + 3 refactors Shells + 1-2 mocks + 3-5 modèles)

**Statut :** spécification validée → transmission à 🏗️ Architecture
