# 🎨 Proposition UI/UX — V9.2 Cards système + PartenariatDetailScreen

> **Version :** 1.0
> **Date :** 2026-05-11
> **Options choisies :** A=3 zones / B=text3 muted / C=2 cards empilées
> **Status :** ✅ Validée

---

## Design UI Validé

### Réutilisations
- `DynamicAppBar`, `IconBoutton`, palette `AppColors`, tokens `AppRadii.sm(10)/md(14)/pill(99)`, `AppTextStyles.h3/body/small/eyebrow/mono`
- `UserAvatar` (V8) ou pattern avatar gradient or projet
- `FcfaFormatter.full` si prix affiché dans card résa
- `url_launcher` (déjà ajouté V9.7c) pour bouton phone

---

## 1. Skeleton cards — Option A "3 zones"

Pattern statique (pas de shimmer), zones gris `bgElev2` qui pré-figurent le contenu final.

### ReservationMessageCard — Loading
```
╭──────────────────────────────────────╮
│ ┌───┐                                │  
│ │ ⓘ │ RÉSERVATION                    │  ← eyebrow accent fixe
│ │   │                                │  ← icon 40×40 accent or
│ └───┘ ███████████████████            │  ← zone titre (h ~14, w ~160)
│       ████████████                   │  ← zone sub-line (h ~12, w ~110)
│       ████████                       │  ← zone code mono (h ~11, w ~80)
╰──────────────────────────────────────╯
   bgElev1 / border line / padding 12 / radius lg (20)
```
- Icon 40×40 radius md `Icons.event_outlined` accent or
- Eyebrow "RÉSERVATION" fixe (toujours visible même en loading)
- 3 Container `bgElev2` radius `sm` (10) avec hauteurs/largeurs fixes — pas d'animation
- Espacement vertical 8px entre zones

### ReservationMessageCard — Loaded
```
╭──────────────────────────────────────╮
│ ┌───┐ RÉSERVATION                    │
│ │ 📅│ Studio Plateau lumineux        │  ← h3 max 1 ligne ellipsis
│ │   │ 12 – 15 nov · 3 nuits          │  ← small text2
│ └───┘ ASF-7K2N9 · 120 000 FCFA      │  ← mono accent + total FCFA
╰──────────────────────────────────────╯
```

### ReservationMessageCard — Error fallback (Option B text3 muted)
```
╭──────────────────────────────────────╮
│ ┌───┐ RÉSERVATION                    │
│ │ 📅│ Réservation ASF-7K2N9          │  ← fallback titre = ref
│ │   │ ┌──────────────┐               │  
│ └───┘ │⊕ Indisponible│              │  ← chip text3 muted
│       └──────────────┘               │
╰──────────────────────────────────────╯
```
- Chip `Container` bgElev2 + border `line` + padding 5×10 + radius `pill`
- Icon `Icons.info_outline` 12 text3 + texte "Indisponible" 11 w600 text3
- Tap card désactivé (loaded == null)

### AcceptedPartenariatMessageCard — 3 états identiques pattern

```
╭──────────────────────────────────────╮
│ ┌───┐ DEMANDE ACCEPTÉE               │  ← eyebrow success
│ │ 🤝│ ███████████████                │
│ │   │ ███████████                    │
│ └───┘                                │
╰──────────────────────────────────────╯
   icon Icons.handshake_outlined accent or 40×40
```

**Loaded** :
```
╭──────────────────────────────────────╮
│ ┌───┐ DEMANDE ACCEPTÉE               │
│ │ 🤝│ Yao A.                         │  ← nom proprio (ou démarcheur selon contexte)
│ │   │ Accepté le 11 mai              │  ← repondueAt formaté
│ └───┘                                │
╰──────────────────────────────────────╯
```

**Error** :
```
╭──────────────────────────────────────╮
│ ┌───┐ DEMANDE ACCEPTÉE               │
│ │ 🤝│ Partenariat #12                │
│ │   │ ⊕ Indisponible                 │
│ └───┘                                │
╰──────────────────────────────────────╯
```

---

## 2. PartenariatDetailScreen — Option C "2 cards empilées"

```
┌─────────────────────────────────────────┐
│  ← Demande de partenariat               │  ← DynamicAppBar
│                                          │
│  ─── STATUT ────────────────────────    │  ← eyebrow
│                                          │
│  ┌───────────────────────────────────┐  │
│  │  ✓ Acceptée                       │  │  ← chip large success
│  │  Envoyée le 10 mai · Acceptée le 11│  │  ← sub-line dates
│  └───────────────────────────────────┘  │
│                                          │
│  ─── PARTIES ───────────────────────    │  ← eyebrow
│                                          │
│  ┌───────────────────────────────────┐  │
│  │ ⓥ DÉMARCHEUR                  ☎  │  │  ← Card 1
│  │   Aminata K.                      │  │
│  │   +225 07 99 12 34                │  │
│  └───────────────────────────────────┘  │
│                                          │
│  ┌───────────────────────────────────┐  │
│  │ ⓟ PROPRIÉTAIRE                ☎  │  │  ← Card 2
│  │   Yao A.                          │  │
│  │   +225 01 23 45 67                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### PartenariatDetailStatusSection
- Container bgElev1 + border line + padding 16 + radius md
- Eyebrow "STATUT" text3
- Row : chip statut + Spacer (chip aligné gauche)
- Sub-line dates : `AppTextStyles.small.copyWith(fontSize: 12, color: text2)`
- Chip statut large : padding 8×14 + radius pill + selon statut :
  - `ACCEPTEE` → bg `success.withAlpha(0.14)` + text `success` + icon `Icons.check_circle_outline`
  - `EN_ATTENTE` → bg `warn.withAlpha(0.14)` + text `warn` + icon `Icons.schedule_outlined`
  - `REFUSEE` → bg `danger.withAlpha(0.14)` + text `danger` + icon `Icons.cancel_outlined`

### PartenariatDetailPartyCard
- Container bgElev1 + border line + padding 16 + radius `md` (14)
- Row gap 12 :
  - **Avatar 48×48** : gradient or (`AppColors.avatarGradientStart` → `avatarGradientEnd`) circle, initiales `onAccent` w600 18
  - **Expanded Column** :
    - Eyebrow rôle uppercase (DÉMARCHEUR / PROPRIÉTAIRE) `AppTextStyles.eyebrow`
    - Spacing 4
    - Nom `AppTextStyles.h3` max 1 ligne ellipsis
    - Spacing 2
    - Téléphone `AppTextStyles.mono(AppTextStyles.small.copyWith(fontSize: 12, color: text3))`
  - **IconBoutton phone** : `Icons.phone_outlined` accent or 20, `onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone))`
  - Si tel vide → IconBoutton disabled (opacity 0.4)

### Layout body
- `SingleChildScrollView` + Column `crossAxisAlignment: start`
- Padding 18 horizontal
- Eyebrow "STATUT" + SizedBox 10 + StatusSection + SizedBox 24
- Eyebrow "PARTIES" + SizedBox 10 + PartyCard démarcheur + SizedBox 12 + PartyCard proprio + SizedBox 24

---

## 3. Spec détaillée par token

| Élément | Token |
|---|---|
| Card bg | `AppColors.bgElev1` |
| Card border | `AppColors.line` |
| Card radius | `AppRadii.lg` (20) pour message cards / `AppRadii.md` (14) pour party cards |
| Card padding | 12 (message cards) / 16 (party cards) |
| Icon container | 40×40, radius `AppRadii.md` (14), bg `AppColors.accentSoft`, icon accent or |
| Avatar | 48×48 circle, gradient `avatarGradientStart → avatarGradientEnd`, initiales onAccent w600 |
| Eyebrow | `AppTextStyles.eyebrow` (11 w600 uppercase letterSpacing 1.2 text3) |
| Eyebrow accent (RÉSERVATION) | eyebrow + color override `AppColors.accent` |
| Eyebrow success (DEMANDE ACCEPTÉE) | eyebrow + color override `AppColors.success` |
| Skeleton zone | Container bg `AppColors.bgElev2`, radius `AppRadii.sm` (10), height 12-14 selon ligne |
| Skeleton zone widths | titre 160, sub 110, code 80 (approximatifs, peut varier ±20px) |
| Chip "Indisponible" | bg `AppColors.bgElev2`, border `AppColors.line`, padding 5×10, radius pill, icon `info_outline` 12 text3 + texte 11 w600 text3 |
| Chip statut large | padding 8×14, radius pill, bg/text selon statut (success/warn/danger) |
| Spacing vertical entre sections | 24 |
| Spacing vertical entre party cards | 12 |
| Spacing horizontal Row content | 12 (gap entre icon/avatar et content) |

---

## 4. Comportements

### ReservationMessageCard
| État | Visuel |
|---|---|
| Initial mount | Skeleton (3 zones gris) + icon accent fixe + eyebrow fixe |
| Loading (fetch en cours) | Identique au initial — skeleton statique |
| Loaded | Skeleton remplacé par titre h3 + sub-line dates + ligne code mono accent |
| Error | titre = "Réservation {ref}" + chip "Indisponible" text3 + tap désactivé |
| Tap (loaded) | Propage `Reservation` au parent → push `LocataireDetailScreen` |
| Tap (error/loading) | Aucun effet (callback null) |

### AcceptedPartenariatMessageCard
| État | Visuel |
|---|---|
| Initial mount | Skeleton 2 zones + icon handshake accent fixe + eyebrow success fixe |
| Loading | Identique |
| Loaded | nom partie pertinente (proprio si on est démarcheur, démarcheur si on est proprio) + sub-line "Accepté le X" |
| Error | "Partenariat #{id}" + chip "Indisponible" |
| Tap (loaded) | Propage `DemandePartenariat` au parent → push `PartenariatDetailScreen` |

### PartenariatDetailScreen
| Élément | Action |
|---|---|
| Back arrow | `back(context)` |
| Bouton phone Card démarcheur | `launchUrl(Uri(scheme: 'tel', path: telephoneDemarcheur))`, SnackBar si échec |
| Bouton phone Card proprio | Idem avec téléphone proprio |
| Tap card (en général) | Aucun (info-only screen) |

---

## 5. Accessibilité
- Contraste `text` (#F5F5F7) sur `bgElev1` (#131316) → 17.5:1 ✓ AAA
- Contraste `accent` (#E8B86B) sur `bgElev1` → 7.5:1 ✓ AAA
- Contraste `text3` (#76767E) sur `bgElev2` (#1C1C20) → 4.3:1 ✓ AA
- Chip "Indisponible" text3 sur bgElev2 → 4.3:1 ✓ AA
- Tap targets : IconBoutton phone ≥ 44×44 (avec padding), avatars/icons non tappables 40×40 minimum
- Eyebrow rôle (DÉMARCHEUR/PROPRIÉTAIRE) en uppercase pour screen readers

## 6. Performance
- Skeleton statique (pas d'animation) → 0 frame overhead
- Cards fetch en parallèle si plusieurs dans la conv (async via Future.wait potentiel future optim)
- Cache HTTP standard pour `getByReference` et `getDemandeById`
- `mounted` checks systématiques avant `setState` post-await
- `IconBoutton phone` `disabled` (opacity 0.4) si tel vide → pas de crash launchUrl

---

## 7. Cas particuliers tranchés

| Cas | Décision |
|---|---|
| Card AcceptedPartenariat - quel nom afficher (démarcheur ou proprio) ? | Le nom de la **partie opposée** : si l'utilisateur courant est démarcheur, montrer le proprio ; si l'utilisateur est proprio, montrer le démarcheur. À calculer via `UserBloc.state.user.type` |
| Format date `repondueAt` | Date simple "11 mai" (helper inline ou `intl` si dispo) |
| Card width | max 82% screenWidth (cohérent V8 message bubbles) |
| Photo proprio / démarcheur dans card V9.2 | Pas de photo MVP — seulement nom (le DTO backend ne renvoie pas d'avatar) |
| Avatar PartenariatDetailScreen | Initiales générées depuis nom (1er char prenom) |
