# 🔌 Plan d'intégration du prototype dans le projet Asfar

> **Source d'analyse :** exploration complète de `lib/` au 2026-05-07.
> **Compagnons :** [`01-prototype-screens-analysis.md`](./01-prototype-screens-analysis.md), [`02-flutter-component-priority.md`](./02-flutter-component-priority.md).

---

## 🎯 Décision architecturale critique

Avant tout chiffrage : **le dark "Asfar Premium" est-il…**

| Option | Signification | Impact |
|---|---|---|
| **A. Refonte totale (v2)** | Le prototype définit la nouvelle identité Asfar. Le thème clair actuel est legacy à remplacer. | 500+ écrans à migrer ; 6-12 semaines |
| **B. Tier premium coexistant** | Le clair reste pour les utilisateurs free, le dark s'active pour des comptes premium ou des features payantes. | Coexistence permanente ; 2-3 semaines pour le squelette |
| **C. Refonte sélective** | Nouvelles features uniquement en dark, anciens écrans gardent le thème clair indéfiniment. | Pas de rebrand. UX hybride. 1 semaine pour le squelette |

> ⚠️ **Cette décision conditionne tout le plan ci-dessous.** Mon hypothèse de travail par défaut : **option A** (le prototype = nouvelle identité), avec une migration progressive feature-par-feature pour limiter le risque. Si c'est B ou C, certaines sections sont à ajuster.

---

## 📊 État du projet existant (résumé)

### Structure `lib/` (44 sous-dossiers de widgets)

```
lib/
├── bloc/             # 21 BLoCs (flat, NON séparés par rôle)
├── widget/           # 44 sous-dossiers : button/, input/, card/, appbar/,
│                     #   bottom_nav/, notification/, form/, text/, badge/,
│                     #   dialog/, loader/, map/, message/, calendar/, …
├── screen/
│   └── client/
│       ├── locataire/   # 5+ écrans (home, explore, booking, favorite, profile)
│       ├── proprio/     # 10+ écrans (appartements, reservations,
│       │                #   comptabilite, demarcheurs, inbox, …)
│       └── demarcheur/
├── theme/
│   ├── app_colors.dart  # Palette CLAIRE uniquement
│   ├── app_theme.dart   # ThemeData.light() — "Mode clair uniquement"
│   └── palettes/        # apartment + avatar palettes
├── service/          # API, Firebase, Hive, WebSocket
├── model/
├── repository/
├── util/             # navigation.dart, formate.dart, …
└── config/
```

### Thème actuel — **CLAIR seulement**

| Token actuel | Valeur | Token prototype | Valeur dark | Conflit |
|---|---|---|---|---|
| `AppColors.background` | `#FFFFFF` blanc | `--bg` | `#0A0A0B` quasi-noir | 🔴 inversion totale |
| `AppColors.accent` | `#FFA02A` orange | `--accent` | `#E8B86B` or chaud | 🟡 décalage chromatique |
| `AppColors.textPrimary` | `#1D1D1D` noir | `--text` | `#F5F5F7` blanc cassé | 🔴 inversion |
| `AppColors.surfaceVariant` | `#F5F5F5` | `--bg-elev-2` | `#1C1C20` | 🔴 |

> **L'orange `#FFA02A` actuel et l'or `#E8B86B` du prototype sont visuellement proches en H mais l'or prototype est plus désaturé / chaud / luxueux.** Le prototype a clairement été conçu comme un repositionnement de marque, pas une simple variation sombre.

### Composants existants pertinents

#### Widgets qui se mappent à des composants prototype

| Existant (lib/widget/) | Équivalent prototype | Action |
|---|---|---|
| `button/custom_button.dart` (filled orange) | `AsfarButton primary` | À doubler en `AsfarButton`, conserver `CustomButton` legacy |
| `button/outlined_custom_button.dart` | `AsfarButton secondary` | Idem |
| `button/plain_button.dart` | `AsfarButton ghost` | Idem |
| `input/input_field.dart` | `AsfarInput` | Idem |
| `card/appartement_preview_card.dart` | `AsfarListingCard` | Nouveau widget — l'existant garde son thème clair |
| `appbar/dynamic_appbar.dart` | `AsfarTopNav` | Nouveau widget |
| `bottom_nav/bottom_nav.dart` | `AsfarTabBar` | Nouveau widget — l'existant a la nav blanche actuelle |
| `text/text_seed.dart` (utilisé 80+ fois) | `AsfarTextStyles.*` | **Ne pas migrer**, créer styles directs via `Text(style: AsfarTextStyles.h2)` côté nouveau code |
| `notification/*` | (pas encore au prototype) | Conserver tel quel |
| `calendar/*` | `ProprietaireBookingCalendar` | À recréer côté Asfar pour le rendu dark |

#### Widgets sans équivalent (existant pur — ne pas toucher)

`form/`, `dialog/`, `loader/shimmer_card.dart`, `error_widget.dart`, `bottom_dialogue.dart`, `qr_*`, `mobile_scanner_*`.

### Navigation — Navigator 1.0

- `push/pop` natif via `Navigator.push(MaterialPageRoute(...))`.
- Helpers centralisés dans `lib/util/navigation.dart` : `pushScreen<T>()`, `pushAndRemoveAll()`, `navigateToMenuTab()`, `back<T>()`.
- `navigatorKey` global dans `main.dart` (pour gérer expiration token).
- Pas de `go_router` / `auto_route` → migration éventuelle est un **chantier séparé**, pas un prérequis.

### State management — BLoC flat

- 21 BLoCs **non séparés par rôle** (`reservation_bloc/` mélange locataire & proprio actions).
- **Règle SOLID projet :** nouveau code = BLoCs séparés (`TenantBookingBloc` vs `LandlordBookingBloc`), existant pas refactoré.
- Pas de `ThemeBloc` actuel → à créer si besoin de toggle clair/dark.

### Localisation & format

- 🇫🇷 Français only, hardcodé partout (mois, libellés).
- `intl` importé pour `initializeDateFormatting('fr_FR')` mais **pas de l10n auto-générée**.
- `lib/util/formate.dart` a `helpAmountFormate()` — pas de formatter FCFA dédié → à créer (`AsfarFcfaFormatter`).

---

## 🚦 Conflits & blockers identifiés

| # | Conflit | Sévérité | Mitigation |
|---|---|---|---|
| 1 | App entièrement claire, `ThemeData.light()` only | 🔴 HAUTE | Ne pas écraser `AppColors`. Créer `lib/theme/asfar/asfar_colors.dart` séparé. |
| 2 | Pas de mécanisme de switch clair/dark | 🔴 HAUTE | Si option A → `MaterialApp(theme: AsfarTheme.dark)` directement. Si B/C → ajouter `ThemeBloc`. |
| 3 | Couleurs hardcodées dans 100+ widgets via `AppColors.xxx` | 🟡 MOYENNE | Les anciens widgets restent en clair. Nouveaux widgets `Asfar*` n'utilisent QUE `AsfarColors.xxx`. |
| 4 | `TextSeed` utilisé 80+ fois avec styling manuel | 🟡 MOYENNE | Ne pas toucher. Nouveau code utilise `Text(..., style: AsfarTextStyles.h3)` directement (sans wrapper). |
| 5 | `BottomNav` custom blanc, hardwired 5 tabs locataire | 🟡 MOYENNE | Créer `AsfarTabBar` côté nouveau, `BottomNav` reste pour le clair. Si option A : remplacer dans `Home()` au moment de la migration locataire. |
| 6 | `BLoCs` flat non séparés par rôle (violation SOLID) | 🟢 FAIBLE | Pas un blocker design — règle interne du projet. Nouveau code = BLoCs séparés. |
| 7 | `backdrop-filter` Liquid Glass moins fiable sur Android < 12 | 🟢 FAIBLE | Fallback opaque `bgElev1` solid via `Theme.of(context).platform`. |
| 8 | SF Pro Display non redistribuable | 🟢 FAIBLE | `Inter` via `google_fonts` comme fallback Android (rendu très proche). |
| 9 | `appbar/dynamic_appbar.dart` & `bottom_nav/bottom_nav.dart` codés en dur blanc | 🟡 MOYENNE | Créer variantes `AsfarTopNav` & `AsfarTabBar`. Côte à côte. |
| 10 | Spécif `refactor-couleurs-fond-blanc/` historique | 🟢 FAIBLE | Indique que la marque a déjà bougé vers le clair. Si on bascule en dark, vérifier qu'il ne reste pas de chantier en cours sur le clair. |

---

## 🛠️ Plan d'intégration recommandé

### 🅰️ Si refonte totale (option A — hypothèse par défaut)

#### Phase 0 — Préparation (1 jour)

- [ ] Valider la décision avec le décideur produit : **on bascule sur le dark Asfar Premium pour TOUS les utilisateurs**.
- [ ] Créer le dossier `lib/theme/asfar/` parallèle (sans toucher `lib/theme/app_colors.dart` ni `app_theme.dart`).
- [ ] Créer le dossier `lib/widget/asfar/` parallèle (sans toucher les sous-dossiers existants).
- [ ] Vérifier les chantiers en cours dans `.ai-outputs/specs/` qui touchent au visuel — les flagger pour migration.

#### Phase 1 — Vague 1 fondations (1-2 jours)

Voir [`02-flutter-component-priority.md`](./02-flutter-component-priority.md) §V1.

**Livrables :**
- `lib/theme/asfar/asfar_colors.dart`
- `lib/theme/asfar/asfar_text_styles.dart`
- `lib/theme/asfar/asfar_radii.dart`
- `lib/theme/asfar/asfar_theme.dart` (export `ThemeData.dark()` configuré)
- `lib/util/asfar_fcfa_formatter.dart`
- `lib/widget/asfar/asfar_image_placeholder.dart` × 4 tones
- `lib/widget/asfar/asfar_map_placeholder.dart`
- `lib/widget/asfar/asfar_avatar.dart`
- `lib/widget/asfar/asfar_blur_container.dart`
- `lib/widget/asfar/asfar_icon.dart` (avec `lucide_icons` ou pack équivalent — à ajouter dans `pubspec.yaml`)

**Important :** ne **PAS** activer `AsfarTheme` dans `MaterialApp` à cette phase. Garde-fou : tester via une `Storybook` route dédiée.

#### Phase 2 — Vague 2 atomes (2-3 jours)

Voir §V2 du fichier 02. Toujours en parallèle, sans rien casser.

#### Phase 3 — Vague 3 molécules (3-4 jours)

Voir §V3 du fichier 02.

#### Phase 4 — Bascule du thème global (1/2 jour) ⚠️ POINT DE NON-RETOUR

Au moment où la base est solide :

```dart
// lib/main.dart
MaterialApp(
  theme: AsfarTheme.dark, // ← bascule
  // ...
)
```

À ce moment, **tous les écrans existants** (qui utilisent `AppColors.background = white`) s'afficheront mal car :
- Ils auront un fond blanc dans un contexte attendant fond noir.
- Mais le `Theme.of(context).scaffoldBackgroundColor` sera dark.
- Si les écrans utilisent `AppColors.background` en dur → ils restent blancs (conflit visuel).
- Si les écrans utilisent `Theme.of(context)...` → ils basculent automatiquement (probablement très peu de cas).

→ **À tester sur 5 écrans représentatifs avant de merger.** Si l'inversion casse trop, alternative :
- Ne pas basculer le thème global.
- Migrer écran par écran en remplaçant chaque `AppColors.xxx` par `AsfarColors.xxx` dans les nouveaux écrans Asfar.
- Conserver les anciens écrans avec `AppColors` (ils restent clairs jusqu'à migration).

#### Phase 5 — Migration feature par feature (8-12 semaines)

Pour chaque feature listée dans `lib/screen/client/<role>/<feature>/` :

1. Créer une branche `migrate/<feature>-asfar`.
2. Wrapper l'écran racine dans `Theme(data: AsfarTheme.dark, child: ...)` pour isoler localement.
3. Remplacer les widgets existants par leurs équivalents `Asfar*` :
   - `CustomButton` → `AsfarButton primary`
   - `InputField` → `AsfarInput`
   - `AppartementPreviewCard` → `AsfarListingCard`
   - `DynamicAppBar` → `AsfarTopNav`
4. Remplacer les références `AppColors.*` → `AsfarColors.*`.
5. Remplacer `TextSeed(text, fontSize: 18)` → `Text(text, style: AsfarTextStyles.h2)`.
6. Tester visuellement contre le prototype HTML correspondant (les 18 écrans listés dans le doc 01).
7. Audit + merge.

**Ordre suggéré (du moins risqué au plus risqué) :**

| Sprint | Périmètre | Pourquoi en premier/dernier |
|---|---|---|
| 1 | Onboarding + Profile (2 écrans) | Indépendants, faible churn |
| 2 | Locataire Home + Detail (2 écrans) | Vitrine produit, gain perçu fort |
| 3 | Locataire Search + Reserve + Trips (3 écrans) | Tunnel critique, à tester à fond |
| 4 | Démarcheur Dashboard + Wallet (2 écrans) | Périmètre limité, identité visuelle distinctive |
| 5 | Démarcheur New + Detail (2 écrans) | |
| 6 | Propriétaire Dashboard + Finances (2 écrans) | Charts complexes — sprint plus lourd |
| 7 | Propriétaire Listings + Edit (2 écrans + 4 tabs) | Gros volume |
| 8 | Messaging List + Thread (2 écrans, partagés 3 rôles) | À faire en dernier (effets de bord chat live) |

---

### 🅱️ Si tier premium coexistant (option B)

- Tout le dossier `lib/theme/asfar/` et `lib/widget/asfar/` reste, mais on ajoute :
  - `lib/bloc/theme_bloc/` (avec `ThemeState.light` / `ThemeState.dark`).
  - Toggle dans `Profile` → dispatch `ThemeBloc.toggle()` → `MaterialApp` reconstruit.
  - Garde sur les routes : `if (user.isPremium) → AsfarTheme else → AppTheme`.
- Phase 4 (bascule globale) **ne se fait jamais**.
- Phase 5 (migration) ne s'applique qu'aux features marquées premium.

---

### 🅲 Si refonte sélective (option C)

- Pareil que B mais sans logique premium : juste « certaines features sont déjà en dark, les autres sont en clair ».
- Plus simple à shipper, mais UX hybride permanente — à éviter à long terme.
- Utile comme **étape transitoire** vers A.

---

## 📋 Checklist immédiate (avant de coder)

- [ ] **Décider A / B / C** avec le décideur produit. Ce choix conditionne tout le reste.
- [ ] Vérifier qu'aucune feature en cours dans `.ai-outputs/features/` ne touche à `app_colors.dart` ou à un des 9 widgets en conflit (cf. tableau §Conflits).
- [ ] Choisir le pack d'icônes : `lucide_icons_flutter` recommandé (60+ icônes du proto y sont).
- [ ] Choisir la fonte : `google_fonts: ^6.2` + Inter pour Android, fallback iOS sur SF Pro système.
- [ ] Si option A : prévoir une **revue UX** par écran migré pour valider le rendu vs. prototype.
- [ ] Créer une **route /design-system** privée pour storybook les widgets Asfar isolément.

---

## 🎁 Bénéfices attendus

| Critère | Avant | Après |
|---|---|---|
| Identité visuelle | Tech générique blanc/orange | Premium dark or chaud, signature culturelle assumée |
| Cohérence | Variations chacun-pour-soi (TextSeed × 80) | Tokens centralisés (`AsfarTextStyles`, `AsfarColors`) |
| Maintenance | Couleurs hardcodées partout | Single source of truth |
| Branding | Indéfini | « Voyagez, louez, **gagnez.** » + or = ADN clair |
| Contraintes Android | Pas de Liquid Glass | Blur backdrop fonctionnel (avec fallback) |

## ⚠️ Risques

| Risque | Probabilité | Mitigation |
|---|---|---|
| Régressions visuelles à la bascule globale | 🔴 HAUTE (option A) | Tester sur 5 écrans, prévoir feature flag |
| Lassitude de l'équipe (8-12 semaines de migration) | 🟡 MOYENNE | Ship par feature, revues UX courtes |
| Conflit avec chantier en cours | 🟢 FAIBLE | Audit `.ai-outputs/features/` avant de démarrer |
| Drift produit (proto évolue pendant la migration) | 🟡 MOYENNE | Geler le proto avant migration, ou baseline stricte |
| Performance Liquid Glass sur low-end Android | 🟢 FAIBLE | Fallback opaque déjà prévu |

---

## 🔗 Pour aller plus loin

- **Inventaire écran** → [`01-prototype-screens-analysis.md`](./01-prototype-screens-analysis.md)
- **Liste widgets à créer** → [`02-flutter-component-priority.md`](./02-flutter-component-priority.md)
- **Sources extraites** → `.ai-outputs/prototype-extract/`
