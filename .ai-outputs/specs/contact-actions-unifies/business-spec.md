# 📋 Spécification Métier — Contact Actions Unifiés

> **Feature** : `contact-actions-unifies`
> **Mode** : 🔴 Feature Complète
> **Date** : 2026-05-20
> **Statut** : ✅ Validée par l'utilisateur

---

## 1. Contexte

L'application Asfar contient **6+ écrans** où les utilisateurs (démarcheur, propriétaire, locataire) peuvent **Appeler** ou **Contacter** un interlocuteur. La logique est aujourd'hui **dupliquée inline** dans chaque écran, sans couche partagée — ce qui provoque des incohérences UX et des bugs (notamment sur le détail des demandes côté démarcheur, où les boutons ne fonctionnent plus).

### Écrans concernés par la migration

- `lib/screen/client/demarcheur/referrals/referral_detail_screen.dart` ⚠️ **BUG PRIORITAIRE**
- `lib/screen/client/shared/partenariats/widget/partenariat_detail_party_card.dart`
- `lib/screen/client/shared/reservations/reservation_contact_sheet.dart`
- `lib/screen/client/shared/reservations/widget/reservation_detail_party_card.dart`
- `lib/screen/client/shared/reservations/widget/reservation_detail_actions_bar.dart`
- `lib/screen/client/shared/reservations/widget/reservation_detail_apporteur_externe_card.dart`
- `lib/screen/client/demarcheur/detail/demarcheur_appart_detail_screen.dart`
- `lib/screen/client/demarcheur/referrals/widget/referral_client_card.dart`
- `lib/screen/client/shared/inbox/messaging_thread_screen.dart`
- `lib/screen/client/locataire/booking/widget/host_card.dart`
- `lib/screen/client/proprio/calendrier/widget/step_client_info.dart`

---

## 2. Objectif

Offrir à tout utilisateur un **comportement uniforme et fiable** quand il veut contacter quelqu'un dans l'application, quel que soit l'écran d'origine.

---

## 3. Acteurs

| Acteur | Cible(s) de contact |
|---|---|
| **Démarcheur** | Ses filleuls (clients référés) · Les propriétaires liés à ses listings |
| **Propriétaire** | Ses locataires · Démarcheurs partenaires · Apporteurs externes |
| **Locataire** | L'hôte de son séjour |

---

## 4. Règles métier

### 4.1 Action "Appeler"

- Lance l'application téléphone native via le numéro du contact
- Bouton **désactivé (grisé)** si le contact n'a pas de numéro de téléphone

### 4.2 Action "Contacter" — ouvre une sheet à 3 options

**Ordre fixe dans la sheet :**

| # | Option | Disponibilité |
|---|---|---|
| 1 | 💬 **Chat in-app** | **Toujours active** (crée le thread si absent) |
| 2 | 🟢 **WhatsApp** | Active si numéro WhatsApp existe pour ce contact |
| 3 | 📞 **Appeler** | Active si numéro de téléphone existe |

**Règles d'affichage :**

- **Sheet toujours affichée**, même si une seule option est dispo (cohérence UX)
- Options indisponibles → **grisées** dans la sheet (visibles mais non cliquables)
- Si **les 3** options indispo (cas extrême) → **bouton "Contacter" lui-même grisé**

### 4.3 Disponibilité selon statut

| Rôle | Comportement |
|---|---|
| **Démarcheur** | Actions **toujours actives**, quel que soit le statut (en attente, annulée, refusée, acceptée) |
| **Propriétaire / Locataire** | Actions **désactivées si statut terminal** (annulée, refusée, expirée) |

### 4.4 Cible du contact

- Chaque bouton est **attaché à un contact précis** (proprio OU client OU démarcheur)
- Pas de choix de cible — le widget reçoit son contact en paramètre

---

## 5. Cas d'usage principal

**Scénario nominal — démarcheur contacte son filleul depuis le détail d'une demande**

1. Le démarcheur ouvre le détail d'une demande (statut "en attente")
2. Il tape sur le bouton **Contacter** attaché au filleul
3. Une bottom sheet s'ouvre avec 3 options : Chat / WhatsApp / Appeler
4. Toutes les options sont actives (numéros + WhatsApp dispo)
5. Il choisit **WhatsApp** → l'app WhatsApp s'ouvre avec une conversation préremplie vers le filleul
6. (Alternative) Il choisit **Appeler** → l'app téléphone native s'ouvre
7. (Alternative) Il choisit **Chat** → la conversation in-app s'ouvre (créée si absente)

---

## 6. Cas alternatifs / limites

| Cas | Comportement attendu |
|---|---|
| Contact sans WhatsApp | Option WhatsApp grisée dans la sheet, Chat + Appeler actives |
| Contact sans téléphone du tout | Appeler grisé, WhatsApp grisé, seul Chat actif |
| Demande annulée côté proprio | Boutons Appeler/Contacter complètement grisés |
| Demande annulée côté démarcheur | Boutons actifs (règle métier : peut toujours relancer) |
| Numéro mal formé | Toast d'erreur "Impossible de joindre ce contact" |
| WhatsApp non installé | Toast d'erreur explicite "WhatsApp n'est pas installé" |
| App téléphone indisponible | Toast d'erreur explicite |

---

## 7. Contraintes

- **Bug à corriger en priorité** sur `referral_detail_screen.dart` (détail demande démarcheur)
- **Migration progressive** des 10+ écrans existants (pas de big bang — par lots)
- **Aucune régression** sur les flux qui fonctionnent déjà (réservation, partenariat, chat)
- Compatible **iOS + Android** (pas de feature platform-specific)
- Respect des **règles Flutter du projet** (1 widget = 1 fichier, pas de fonction privée retournant Widget, SOLID sur le nouveau code)

---

## 8. Critères d'acceptation

- [ ] Sur `referral_detail_screen` (démarcheur), **Appeler** ouvre le dialer natif et **Contacter** ouvre la sheet à 3 options
- [ ] La sheet de contact est **identique partout** (même ordre, même style, même règles de grisage)
- [ ] Côté **démarcheur**, les boutons restent actifs même si demande annulée/refusée
- [ ] Côté **proprio/locataire**, les boutons sont grisés si statut terminal
- [ ] Tap sur **"Chat"** depuis n'importe quel écran → ouvre le thread existant ou en crée un nouveau
- [ ] Tap sur **"WhatsApp"** → ouvre WhatsApp si dispo, sinon toast d'erreur explicite
- [ ] Tap sur **"Appeler"** → ouvre le dialer natif si numéro valide, sinon toast d'erreur
- [ ] Bouton "Contacter" grisé **uniquement si les 3 options sont indisponibles**
- [ ] Bouton "Appeler" grisé **uniquement si pas de numéro**
- [ ] Les 10+ écrans listés en §1 utilisent tous le **même composant unifié**
- [ ] Aucune duplication de logique `tel:` / `launchUrl` / `wa.me` dans les écrans (centralisée dans le service)

---

## 🔗 Liens avec autres specs

- Modèle `Contact` à définir/réutiliser (voir architecture)
- Service de conversation existant (`messaging_thread_screen`) à intégrer pour l'option Chat
- `reservation_contact_resolver.dart` existant — à fusionner ou remplacer

---

**✅ Spécification validée — transmise à l'Agent Architecture**
