# 🔍 Rapport d'audit — Vague 6 Démarcheur

> **Auteur :** Agent Audit (workflow `/feature full`)
> **Date :** 2026-05-10
> **Périmètre :** 30 fichiers Dart Vague 6 + 2 fichiers modifiés + 4 tokens AppColors

---

## 📊 Scores

| Dimension | Score | Problèmes | Statut |
|---|---|---|---|
| Complexité | 95/100 | 🚨 0 / ⚠️ 0 / ℹ️ 1 | ✅ |
| Lisibilité | 95/100 | 🚨 0 / ⚠️ 0 / ℹ️ 1 | ✅ |
| DRY (après correction) | 100/100 | 🚨 0 / ⚠️ 0 / ℹ️ 0 | ✅ |
| Documentation | 100/100 | 🚨 0 / ⚠️ 0 / ℹ️ 0 | ✅ |
| SOLID | 100/100 | 🚨 0 / ⚠️ 0 / ℹ️ 0 | ✅ |
| Dette technique | 100/100 | 🚨 0 / ⚠️ 0 / ℹ️ 0 | ✅ |
| **GLOBAL** | **98/100** | | **✅ VALIDÉ** |

---

## 🚨 Problèmes critiques

**Aucun.**

---

## ⚠️ Problèmes majeurs (corrigés pendant l'audit)

### DRY — Duplication helper status display

**Fichier :** `lib/screen/client/demarcheur/referrals/referral_detail_screen.dart` (avant correction lignes 163-187)

**Constat :** L'écran redéfinissait localement `_statusLabel(ReferralStatus)` et `_statusTone(ReferralStatus)` alors que l'helper public `ReferralStatusDisplay.labelOf` et `ReferralStatusDisplay.toneOf` existait déjà dans `lib/screen/client/demarcheur/referrals/widget/referral_status_display.dart` et était déjà utilisé par `ReferralRow` et `ReferralsScreen`.

**Mesure :** 25 lignes dupliquées (2 méthodes × ~12 lignes).

**Correction appliquée :**
```dart
// AVANT
String _statusLabel(ReferralStatus status) { ... 12 lignes ... }
BadgeTone _statusTone(ReferralStatus status) { ... 12 lignes ... }
BadgeStatus(text: _statusLabel(referral.status), tone: _statusTone(referral.status))

// APRÈS
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
BadgeStatus(
  text: ReferralStatusDisplay.labelOf(referral.status),
  tone: ReferralStatusDisplay.toneOf(referral.status),
)
```

**Impact :** -25 lignes, suppression import `badge_tone.dart` devenu inutile. Toute la logique status display centralisée dans 1 seul helper. `flutter analyze` toujours à 41 issues legacy uniquement.

---

## ℹ️ Améliorations suggérées (non bloquantes)

### Complexité — Longueur de fichier `new_referral_screen.dart`

**Fichier :** `lib/screen/client/demarcheur/referrals/new_referral_screen.dart` (315 lignes)

**Constat :** Légèrement au-dessus du seuil mineur de 300 lignes.

**Mesure :** 315 lignes (seuil ⚠️ majeur = 500, ℹ️ mineur = 300).

**Justification du choix :**
- Pattern miroir de `LocataireReserveScreen` Vague 5 (293 lignes, validé en V5)
- Tunnel single screen avec `int _step` est explicitement documenté comme écart conscient (`architecture.md § 3.2`)
- L'extraction des `_step1/2/3` en widgets dédiés multiplierait les fichiers sans bénéfice clair (état du formulaire partagé)

**Correction possible (optionnelle, vague de finition) :** extraire chaque étape en `NewReferralStep1Content`, `NewReferralStep2Content`, `NewReferralStep3Content` (`Stateless` qui prennent les controllers en paramètres). À évaluer si la surface fonctionnelle s'élargit (ex: validation côté serveur, sauvegarde brouillon).

### Lisibilité — Font sizes hardcodés

**Fichiers :** plusieurs (`new_referral_screen.dart:258,265,304,308`, `wallet_hero_card.dart:88`, etc.)

**Constat :** Tailles de police 13/14/17 saisies directement plutôt que comme tokens.

**Mesure :** ~12 occurrences sur les 30 fichiers. Pattern hérité de Vague 5 (cohérence projet).

**Correction possible (refacto transverse, hors Vague 6) :** créer `AppTextSizes` (`small=13`, `body=14`, `subtitle=17`, etc.) et brancher tous les écrans Vagues 1-5-6 en même temps. Hors scope car affecterait des écrans déjà validés.

---

## 🎯 Évolution

| Dimension | Avant | Après correction DRY | Δ |
|---|---|---|---|
| Complexité | 95 | 95 | 0 |
| Lisibilité | 95 | 95 | 0 |
| DRY | 90 | 100 | +10 |
| Documentation | 100 | 100 | 0 |
| SOLID | 100 | 100 | 0 |
| Dette technique | 100 | 100 | 0 |
| **GLOBAL** | **96.7** | **98.3** | **+1.6** |

---

## 📋 Détail par catégorie

### Complexité (95/100)

✅ **Points forts :**
- 29/30 fichiers < 200 lignes
- Aucun "god object" (max 315 lignes)
- Imbrication max 3 niveaux
- Complexité cyclomatique max 5 (switches sur 4 cas)
- Helpers extraits dans fichiers dédiés (`ProfileDisplayInfo`, `ReferralStatusDisplay`)

⚠️ **Points d'attention :**
- ℹ️ `new_referral_screen.dart` 315 lignes > 300 (-5 mineur)

### Lisibilité (95/100)

✅ **Points forts :**
- Aucun nom cryptique (sauf `i` dans boucles, conventionnel)
- Constants nommées (`_generatedRef`, `_filters`, `_steps`)
- Aucune ligne > 120 caractères
- Magic numbers uniquement sur paddings/gaps (pattern proto, valeurs visuelles intentionnelles)
- Cohérence camelCase totale

⚠️ **Points d'attention :**
- ℹ️ Font sizes 13/14/17 hardcodés (pattern Vague 5, refacto transverse hors V6)

### DRY (100/100 après correction)

✅ **Points forts :**
- Atomes/molécules Vagues 1-5 réutilisés massivement (`BadgeStatus`, `AsfarChip`, `BlurContainer`, `DynamicAppBar`, `BottomNav`, `ListingSummaryCard`, `HostCard`, `InfoBanner`, `SuccessCircle`, `ImgPh`, `UserAvatar`, `InputField`, `SectionHeader`, `BottomNavTabs.demarcheur`)
- Helpers extraits pour mappings (`ProfileDisplayInfo`, `ReferralStatusDisplay`)
- Mocks isolés dans `sample/` (séparation données / présentation)

✅ **Correction appliquée :**
- ⚠️ Duplication `_statusLabel`/`_statusTone` dans `referral_detail_screen.dart` → utilise `ReferralStatusDisplay`

### Documentation (100/100)

✅ **Points forts :**
- 100 % des classes publiques ont une doc commentaire
- Référence systématique au proto (fichier JSX + ligne)
- Helpers documentés avec exemples
- `ProfileDisplayInfo`, `ReferralStatusDisplay`, `MiniStatItem`, `StatusPillItem`, `TimelineEntry` documentés
- Modèles UI-only `ReferralPreview`, `CommissionTransaction` expliquent leur rôle vs modèles métier

### SOLID (100/100)

✅ **Single Responsibility :**
- Chaque widget a 1 responsabilité visuelle
- Helpers font une seule chose (mapping role → display, status → label/tone)
- Screens orchestrent uniquement (pas de logique métier)

✅ **Open/Closed :**
- `ReferralStatusDisplay` permet d'ajouter un statut sans toucher aux 3 widgets qui l'utilisent
- `ProfileDisplayInfo.forRole` permet d'ajouter un rôle sans toucher au screen

✅ **Liskov / Interface Segregation / DI :**
- Pas d'héritage dans le scope Vague 6 (composition stricte)
- Pas d'interfaces (UI Flutter pure)
- Dépendances injectées via constructeur (BLoC via Provider, mocks via `static const`)

### Dette technique (100/100)

✅ **Points forts :**
- 0 TODO / FIXME / HACK / XXX dans le code
- 0 `print()` debug
- 0 `catch {}` vide
- 0 code commenté
- TODO REBUILD documentés dans `RECONSTRUCTION_UI_ASFAR.md` (et non dans le code) :
  - Empty states (post-V9 quand BLoCs branchés)
  - UX retrait Wallet (F9 Banque)
  - Persistance switch de rôle (event UserBloc dédié)

---

## ✅ Verdict final

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ AUDIT VALIDÉ — SCORE 98/100                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  • 0 problème critique                                        ║
║  • 1 problème majeur DRY → corrigé pendant l'audit            ║
║  • 2 améliorations mineures notées (refacto transverse,      ║
║    hors scope Vague 6)                                        ║
║                                                               ║
║  → Documentation HTML (ÉTAPE 8) peut démarrer.                ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

**Statut :** AUDIT VALIDÉ → transmission à 📄 Documentation.
