# 🎨 Propositions UI/UX : Écrans hors prototype

> **Auteur :** UI/UX Agent (workflow `/feature full`)
> **Date :** 2026-05-07
> **Statut :** En attente de choix d'option pour chaque famille
> **Périmètre :** ~22-30 écrans présents dans l'app mais absents du prototype HTML
> **Contrainte :** rester dans le langage Asfar Premium (tokens, composants, patterns du proto)

---

## 🎨 Analyse UI/UX

**Environnement détecté :**
- **Type :** Mobile Flutter (iOS 13+ / Android 10+)
- **Framework :** Flutter avec ThemeData dark Asfar Premium (post-refonte V1)
- **Langage :** Dart 3 + JSX prototype comme référence visuelle

**Fichiers UI identifiés :**
- `lib/screen/<feature>/*.dart` — vues
- `lib/widget/<thème>/*.dart` — composants réutilisables Asfar (post-V2/V3)

**Patterns observés (post-refonte) :**
- **Top nav :** safe area + 3 colonnes (left 40 / center title+eyebrow / right 40)
- **Cards** : `bgElev1` + border `line` + radius lg (20)
- **Hero cards** : gradient sombre + halo radial (or pour proprio, bleu pour démarcheur)
- **CTA bottom** : sticky + blur + `accent` primary
- **Tunnel multi-étapes** : sub-eyebrow `Étape n/N` dans top nav
- **Confirmation success** : `SuccessCircle` 88px + halos concentriques
- **Forms** : `FieldRow` (eyebrow + value + edit icon) ou `Input`/`TextField` selon édition vs affichage
- **Listes** : `listrow` avec divider, leading + title/subtitle + trailing

**Contraintes :**
- Tous les écrans doivent **réutiliser** les composants Asfar (pas de nouveaux patterns visuels)
- Cohérence avec les 18 écrans du prototype
- Respecter les flows métier existants (BLoCs intacts)

---

## 🗂️ Familles d'écrans à designer

| # | Famille | Nb écrans | Volume design |
|---|---|---|---|
| F1 | **Auth** (login, signup, OTP, vérif identité) | 6 | Standard |
| F2 | **Wizard création appartement** | 5-7 étapes | Élevé |
| F3 | **Scanner QR / check-in** | 1-2 | Faible |
| F4 | **Comptabilité étendue** (charges, formulaires, graphes) | 5-7 | Élevé |
| F5 | **Démarcheurs côté proprio** | 2-3 | Standard |
| F6 | **Notifications** (page + détail) | 1-2 | Faible |
| F7 | **Carte réelle géocodée** | 1-2 | Standard |
| F8 | **Receipt / PDF** | 1 | Faible |
| F9 | **Banque / Cartes / Compte** | 2-3 | Standard |
| F10 | **Calendrier global réservations** | 1 | Faible |

---

## F1 — 🔐 Auth (login / signup / OTP / vérif identité)

### Contexte
L'onboarding choix-de-rôle existe au prototype (cf. `extras.jsx Onboarding`). Manquent : login email/téléphone, formulaire signup, écran OTP, vérification d'identité.

### Option A — **"Continuité prototype Onboarding"** ⭐ recommandée
Reprend le hero radial gradient or + logo + display title, puis remplace les 3 cartes rôle par des inputs.

```
┌──────────────────────────────┐
│ [ halo radial or top-left ]  │
│                              │
│ [A] asfar                    │ ← logo
│                              │
│ Bienvenue,                   │ ← display
│ connectez-vous.              │   (« connectez-vous » accent)
│                              │
│ EMAIL OU TÉLÉPHONE           │ ← eyebrow
│ [────────── input ─────────] │
│ MOT DE PASSE                 │ ← eyebrow
│ [────────── input ─────────] │
│              Mot de passe ?  │ ← lien accent
│                              │
│ ┌────── Se connecter ──────┐ │ ← btn primary lg
│                              │
│ ─────────── ou ──────────── │
│                              │
│ ┌─ Continuer avec Google ─┐ │ ← btn secondary
│ ┌─ Continuer avec Apple ──┐ │
│                              │
│ Pas de compte ?              │
│ S'inscrire (accent)          │
└──────────────────────────────┘
```
**Composants utilisés :** logo Asfar, hero radial existant, `Input`, `CustomButton primary/secondary`, `TextSeed.display/.eyebrow/.body`.
**Avantages :** cohérence absolue avec onboarding proto. Familier, brandé.
**Inconvénients :** halo radial peut être lourd visuellement sur form long.

### Option B — **"Form premium minimaliste"**
Top nav minimal + form bgElev1 card pleine hauteur. Pas de hero. Plus austère, plus rapide.

```
┌──────────────────────────────┐
│ [ ←  Connexion              ]│ ← top nav
│                              │
│ ┌── Card bgElev1 ──────────┐ │
│ │  Bonjour 👋              │ │ ← h1
│ │  Heureux de vous revoir  │ │ ← body
│ │                          │ │
│ │  EMAIL                   │ │
│ │  [───── input ────────]  │ │
│ │  MOT DE PASSE            │ │
│ │  [───── input ────────]  │ │
│ │                          │ │
│ │ [── Se connecter ──]     │ │
│ └──────────────────────────┘ │
│                              │
│  Mot de passe oublié ?       │
│  Pas de compte ? Inscription │
└──────────────────────────────┘
```
**Avantages :** rapide à scroller, focus form.
**Inconvénients :** moins « waouh », plus admin-style.

### Option C — **"Phone-first avec OTP direct"**
Inspiré des apps africaines : pas de mot de passe. On entre le téléphone → OTP envoyé.

```
┌──────────────────────────────┐
│ [A] asfar                    │
│                              │
│ Connexion rapide.            │ ← h1
│ Recevez un code par SMS.     │ ← body
│                              │
│ NUMÉRO DE TÉLÉPHONE          │
│ [🇨🇮 +225] [── 07 84 21 ──]  │ ← phone input
│                              │
│ ┌── Recevoir le code ──┐     │ ← btn primary
│                              │
│ Email & mot de passe →       │ ← lien accent (option B)
└──────────────────────────────┘
```
**Avantages :** UX adaptée Côte d'Ivoire (pas de pwd à mémoriser, mobile money habitudes).
**Inconvénients :** dépend de la dispo SMS gateway en prod, fallback email obligatoire.

> **Reco :** Option **A** par défaut (continuité visuelle proto). Option C si la cible CI privilégie phone-first (à valider avec produit).

---

## F2 — 🏠 Wizard création d'appartement

### Contexte
5-7 étapes pour qu'un proprio publie une annonce : type → adresse → photos → équipements → tarifs → règles → publication.

### Option A — **"Tunnel proto réutilisé"** ⭐ recommandée
Reprend exactement le pattern `LocataireReserve` 3 étapes / `DemarcheurNew` 3 étapes : top nav avec sub `Étape n/N`, scroll body, bottom CTA primary blur.

```
┌──────────────────────────────┐
│ [ ←  Mon annonce            ]│
│      Étape 3 / 7             │ ← eyebrow sub
│                              │
│ Photos du logement           │ ← h2
│ Au moins 5 photos.           │ ← body
│                              │
│ ┌─ ImgPh ──┬─ ImgPh ──┐      │
│ │          │          │      │
│ └──────────┴──────────┘      │
│ ┌─ ImgPh ──┬─ + ajout ┐      │ ← grid 2 cols
│ │          │ (dashed) │      │
│ └──────────┴──────────┘      │
│                              │
│ Réorganiser, supprimer, ...  │
│                              │
│ ┌── Continuer ──┐ (bottom)   │ ← blur sticky
└──────────────────────────────┘
```
**Composants :** `DynamicAppBar` avec sub, scroll, `WizardCircleProgress` existant + `WizardNavigationBar` modifié au style Asfar, `ImgPh`, grid 2 cols, dashed `+ ajout`.
**Avantages :** identique aux tunnels du proto. Cohérence absolue. Réutilise `wizard/` widgets existants.
**Inconvénients :** 7 étapes long pour un proprio sur mobile.

### Option B — **"Sectionné en accordéon"**
Une seule longue page avec 7 sections accordéon, badge ✓ quand validée.

```
┌──────────────────────────────┐
│ [ ←  Mon annonce            ]│
│                              │
│ Progression : 3 / 7 ✓        │ ← progress bar accent
│ ┌────────────────────────────┐
│ │ ✓ Type d'annonce           ├─┐
│ │ ✓ Adresse                  ├─┤  3 sections complétées
│ │ ▼ Photos (en cours)        ├─┘
│ │   [── form open ──]        │
│ │ ▷ Équipements              │
│ │ ▷ Tarifs                   │
│ │ ▷ Règles                   │
│ │ ▷ Publication              │
│ └────────────────────────────┘
│                              │
│ ┌── Sauvegarder brouillon ─┐ │
└──────────────────────────────┘
```
**Avantages :** vue d'ensemble, sauvegarde par section.
**Inconvénients :** rupture visuelle vs proto (pas de pattern accordéon). Plus lourd à coder.

### Option C — **"Hybride : 3 super-étapes"**
Regroupement en 3 mégas étapes : 1) Identité (type + adresse + photos), 2) Configuration (équipements + tarifs), 3) Règles + publication.

**Avantages :** moins d'étapes, sentiment d'avancement plus rapide.
**Inconvénients :** étapes plus denses, scroll plus long par étape.

> **Reco :** Option **A** (tunnel proto réutilisé, cohérence absolue).

---

## F3 — 📷 Scanner QR / check-in

### Option A — **"Caméra plein écran avec overlay accent"** ⭐ recommandée
```
┌──────────────────────────────┐
│ [ ×                          ]│
│                              │
│   ┌────────────────┐         │
│   │                │         │ ← carré scan animé
│   │   ┌──────┐     │         │   bordure accent or
│   │   │      │     │         │
│   │   └──────┘     │         │
│   │                │         │
│   └────────────────┘         │
│                              │
│ Scannez le QR de la          │
│ réservation                  │
│                              │
│ [── Saisir le code à la main]│ ← btn ghost
└──────────────────────────────┘
```
**Composants :** `mobile_scanner` existant, overlay custom avec accent or animé.

### Option B — **"Carré scan + miniature aperçu"**
Idem mais ajoute en bas une miniature de l'appartement quand le QR est détecté avant validation.

> **Reco :** Option **A** (standard, lisible).

---

## F4 — 💼 Comptabilité étendue

### Contexte
Le proto montre uniquement le P&L synthétique. L'app a en plus : liste des charges détaillées, formulaire d'ajout/édition de charge, vue par appartement, evolution chart, répartition CA chart, dashboard cards multi-périodes.

### Option A — **"Extension du Finances P&L proto"** ⭐ recommandée

Conserve le `PeriodSwitcher` (Sem/Mois/Trim/Année), le hero net, le P&L card. Ajoute en dessous :
- **Section "Mes charges"** avec `StatTile` row + `+ Nouvelle charge` btn
- **Liste des charges** : `listrow` (icône catégorie × badge couleur, libellé, date, montant en mono à droite)
- **Tap sur charge → écran detail** style Asfar (top nav + card hero montant + meta + actions)
- **Formulaire add/edit charge** : `FieldRow` (catégorie, montant, date, appartement, justificatif photo)
- **Charts existants** : `EvolutionChart`, `RepartitionCAChart` repassés en couleurs Asfar (accent or pour valeurs principales, success/danger pour deltas)
- **Selector appartement** : pills horizontaux (chip-active style)

```
┌──────────────────────────────┐
│ [ ←  Finances · Mes charges ]│
│                              │
│ [ Sem | Mois✓ | Trim | Année]│ ← period switcher
│                              │
│ ┌── Card hero ─────────────┐ │
│ │ TOTAL CHARGES NOVEMBRE   │ │
│ │ 722 000 FCFA             │ │ ← mono 30px
│ │ ↓ -8% vs octobre         │ │ ← badge success (baisser = bien)
│ └──────────────────────────┘ │
│                              │
│ ┌──────┬──────┬──────┐       │
│ │ Mén. │ EAU  │ MAINT│       │ ← stat tiles 3 cols
│ │ 168k │ 92k  │ 75k  │       │
│ └──────┴──────┴──────┘       │
│                              │
│ Mes charges     + Nouvelle   │ ← section header
│ ┌──────────────────────────┐ │
│ │ 🧹 Ménage Loft Plateau   │ │
│ │    8 nov · 35 000 FCFA   │ │ ← listrow
│ │ 💧 Eau Cocody            │ │
│ │    5 nov · 12 000 FCFA   │ │
│ │ ...                      │ │
│ └──────────────────────────┘ │
│                              │
│ [── Voir l'évolution ────]   │ ← btn secondary → chart
└──────────────────────────────┘
```

### Option B — **"Onglets Recettes / Charges / Bilan"**
Top nav + 3 onglets soulignés (`UnderlineTabs`) : Recettes / Charges / Bilan. Chaque onglet a son propre scroll.

**Avantages :** segmentation propre, scaling facile.
**Inconvénients :** rupture vs proto qui a tout sur une seule page Finances.

### Option C — **"Dashboard cards riches" (alignée fl_chart)**
Garde le pattern `dashboard_cards.dart` existant mais en cartes Asfar. Pas de re-segmentation. Charts dominants en haut, listes en bas.

> **Reco :** Option **A** (extension naturelle du Finances proto, réutilise les patterns).

---

## F5 — 🤝 Démarcheurs côté proprio

### Contexte
Le proto montre le démarcheur côté démarcheur (dashboard, wallet). L'app a aussi une vue **côté propriétaire** : qui sont mes démarcheurs partenaires, combien me font gagner, demandes de partenariat.

### Option A — **"Dashboard symétrique au démarcheur"** ⭐ recommandée
Reprend le pattern `DemarcheurDashboard` mais inversé :
- **Hero card or** : "Commissions versées ce mois" (au lieu de "Commissions reçues")
- **CTA card** : « Inviter un démarcheur » (au lieu de « Envoyer un client »)
- **Status pills** : N partenaires actifs / N demandes en attente / Taux conversion
- **Liste démarcheurs** : `listrow` avec avatar + nom + nb réservations apportées + total commission

```
┌──────────────────────────────┐
│ [ ↩  Mes démarcheurs        ]│
│                              │
│ ┌── Card or hero ──────────┐ │
│ │ COMMISSIONS VERSÉES MOIS │ │
│ │ 228 000 FCFA             │ │
│ │ ↑ +32% vs octobre        │ │
│ └──────────────────────────┘ │
│                              │
│ ┌── CTA card or ───────────┐ │
│ │ 🤝 Inviter un démarcheur │ │
│ │  Partager mon code       │ │
│ └──────────────────────────┘ │
│                              │
│ ┌─12─┬─3──┬─89%─┐            │ ← status pills
│ │act │ pend│tx  │            │
│ └────┴─────┴────┘            │
│                              │
│ Mes partenaires actifs       │ ← section header
│ ┌──────────────────────────┐ │
│ │ DM  Diallo M.            │ │
│ │     7 réservations · 84k │ │
│ │ JT  Jean T.              │ │
│ │     3 réservations · 45k │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

### Option B — **"Liste simple + filtre statut"**
Pas de hero. Top nav + chips filtres + liste plate de tous les partenariats.
**Avantages :** plus rapide à scanner.
**Inconvénients :** moins valorisant côté proprio.

### Option C — **"Tabs Actifs / Demandes / Historique"**
Onglets soulignés. Chaque onglet a sa logique.

> **Reco :** Option **A** (symétrie avec démarcheur, valorise le proprio).

---

## F6 — 🔔 Notifications

### Contexte
Page complète de notifications (au-delà de l'icône bell du proto). 12 widgets `notification/` existent.

### Option A — **"Liste type Messaging"** ⭐ recommandée
Reprend le pattern `MessagingList` du proto :
- Top nav « Notifications »
- Search bar
- Chips filtre (Toutes / Réservations / Paiements / Système)
- Liste de listrows : icon catégorie + titre + sub + temps relatif + dot accent si non lu

```
┌──────────────────────────────┐
│ [    Notifications         ⚙]│
│                              │
│ [── 🔍 Rechercher ──]        │
│                              │
│ [Toutes✓] [Rés.] [Paie.] [Sys]│
│                              │
│ ┌──────────────────────────┐ │
│ │ 💰 Paiement reçu         │ │
│ │    Rachid B. · 135k FCFA │ │
│ │    Il y a 2h         •   │ │ ← dot non lu
│ │ ─────────────────────────│ │
│ │ 🏠 Nouvelle réservation  │ │
│ │    Loft Plateau · 12 nov │ │
│ │    Hier              •   │ │
│ │ ─────────────────────────│ │
│ │ 💬 Aïcha a répondu       │ │
│ │    Salut, j'arrive...    │ │
│ │    Hier                  │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```
Tap sur notif → bottom sheet détail (`NotificationDetailSheet` existant repassé en couleurs Asfar).

### Option B — **"Groupement par jour"**
Sections « Aujourd'hui » / « Hier » / « Cette semaine ».
**Avantages :** narratif temporel.
**Inconvénients :** plus de scroll.

> **Reco :** Option **A** (cohérence MessagingList).

---

## F7 — 🗺️ Carte réelle géocodée

### Contexte
Le proto a uniquement un placeholder (`map-ph` avec grille + halos + pins prix). L'app utilise `flutter_map` (tiles réelles).

### Option A — **"Tiles dark + pins Asfar"** ⭐ recommandée
- **Tile provider** : Mapbox/MapTiler en theme dark (style "dark-v11" ou équivalent)
- **Pins prix** : repris du proto (badge accent or pour actif, `bgElev2` pour autres)
- **Bouton localisation** : btn flottant rond accent or
- **Bottom sheet** sur tap pin : preview card listing (réutilise `AppartementPreviewCard` modifié)
- **Search bar top** : reprend le `LocataireSearchBar` du proto

```
┌──────────────────────────────┐
│ [ ←  Carte                ⓘ]│
│ ┌──────────────────────────┐ │
│ │ 🔍 Plateau · 3 nuits     │ │ ← search bar style proto
│ └──────────────────────────┘ │
│                              │
│ ░░░░ tiles dark ░░░░░░░░░░░░ │
│ ░░░ [45k] ░░░ [32k]  ░░░░░░░ │
│ ░░░░░░░ [68k✓]  ░░░░░░░░░░░░│  ← pin actif accent
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                              │
│              [📍] ← btn loc │
│                              │
│ ┌── Preview card bas ──────┐ │
│ │ ImgPh  Loft Plateau      │ │ ← bottom sheet
│ │        45k/n · ★4.92     │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

### Option B — **"Tiles claires en filtre dark"**
Si tiles dark trop coûteuses : tile provider standard + overlay rgba dark à 60%.
**Avantages :** moins de provider à payer.
**Inconvénients :** lisibilité dégradée.

> **Reco :** Option **A** (premium). Vérifier coût Mapbox dark vs OSM dark.

---

## F8 — 🧾 Receipt / PDF

### Option A — **"Modal preview PDF + actions"** ⭐ recommandée
- Top nav `Reçu de réservation`
- Card pleine fond `bgElev1` qui mime un reçu papier en dark
- En-tête logo + `Code ASF-7K2N9` mono large
- Récap (logement, dates, montants) en `FieldRow`
- Bottom : 2 btns (Télécharger PDF / Partager)

> Pas d'option B significative — pattern simple.

---

## F9 — 🏦 Banque / Cartes / Compte

### Contexte
Gestion des moyens de paiement utilisateurs (au-delà du choix paiement réservation).

### Option A — **"Wallet style démarcheur, mais récepteur"** ⭐ recommandée
Reprend le pattern `DemarcheurWallet` :
- Hero card bleu-nuit avec « Solde Asfar »
- Btn primary « Retirer maintenant »
- Section « Méthodes de paiement » avec liste de `PaymentMethodTile` (OM / Wave / MTN / cartes)
- Btn secondary « Ajouter un moyen de paiement »
- Section « Historique » des transactions

### Option B — **"Cartes empilées 3D"**
Cards bancaires affichées en pile 3D façon Apple Wallet.
**Avantages :** spectaculaire.
**Inconvénients :** complexe à coder, peu utile sur petit écran.

> **Reco :** Option **A**.

---

## F10 — 📅 Calendrier global réservations (proprio)

### Contexte
Vue cross-appartements : voir toutes les réservations sur un mois donné, tous biens confondus.

### Option A — **"Mois grid + ligne par appart"** ⭐ recommandée
Layout matrix : colonnes = jours du mois, lignes = appartements. Chaque cellule colorée selon réservation/disponible (style proto `BookingCalendar`).

```
┌──────────────────────────────┐
│ [ ←  Calendrier  Nov 2025  →]│
│                              │
│         L M M J V S D L M M  │ ← jours
│ Plateau ░░██████░░██░░░░░░  │ ← rangées par appart
│ Cocody  ░░░░░░██████░░░░░░  │
│ Lagune  ████░░░░░░██████░░  │
│ Almadies░░░░░░░░░░░░░░██░░  │
│                              │
│ █ Réservé   ░ Disponible     │ ← légende
│                              │
│ Tap cellule → détail réserv. │
└──────────────────────────────┘
```

### Option B — **"Calendrier mois + filtre appart en haut"**
Standard mois calendar + chips filtre appart en haut.

> **Reco :** Option **A** (vue cross-appart unique, premium).

---

## ✋ Décisions à prendre

Pour chaque famille, choisis une option. **Mon recommandé par défaut est l'Option A pour toutes**, sauf signalement contraire.

```
╔════════════════════════════════════════════════════════════════╗
║  ✋ VALIDATION UI/UX REQUISE                                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  F1 Auth         : A / B / C / autre  → reco A                 ║
║  F2 Wizard       : A / B / C / autre  → reco A                 ║
║  F3 Scanner QR   : A / B              → reco A                 ║
║  F4 Comptabilité : A / B / C / autre  → reco A                 ║
║  F5 Démarcheurs  : A / B / C / autre  → reco A                 ║
║  F6 Notifs       : A / B              → reco A                 ║
║  F7 Carte        : A / B              → reco A (avec Mapbox)   ║
║  F8 Receipt      : A                  → seule option           ║
║  F9 Banque       : A / B              → reco A                 ║
║  F10 Cal. global : A / B              → reco A                 ║
║                                                                ║
║  Réponse rapide : « tout A » ou liste les exceptions           ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🔚 Suivi

- **Validation utilisateur** → ce document est marqué validé, on passe à 🔧 Flutter Dev
- **Si exceptions** → ce document est révisé, retour validation
- **Composants nouveaux issus de UI/UX** : déjà inclus dans le plan Architecture (cf. liste 15 nouveaux widgets) — pas d'ajout
