# 🎨 Design UI Validé — Refonte Enregistrement Appartement

**Feature** : `refonte-enregistrement-appartement`
**Date** : 2026-05-03
**Option choisie** : **C — Hybrid Smart**

---

## 1. Vue d'ensemble

Wizard 5 étapes en `PageView` avec **densité adaptative** :
- Étapes "interactive" (1 Adresse, 4 Photos) : **plein écran avec bottom sheet sticky**
- Étapes "input court" (2 Titre/type, 3 Capacité, 5 Récap) : **style aéré type Typeform**
- Étape 5 : **page review Airbnb-like** avec preview de l'annonce
- **Édition** : deep-link vers l'étape concernée (long-press carte → "Modifier l'adresse / les photos / le prix")

## 2. Identité visuelle (rappel design system Asfar)

| Élément | Valeur |
|---|---|
| Fond | `AppColors.background` (#FFFFFF) |
| Texte primaire | `AppColors.textPrimary` (#1D1D1D) |
| Accent | `AppColors.accent` (#FFA02A) |
| Surface variant | `AppColors.surfaceVariant` (#F5F5F5) — pour les pills, steppers |
| Erreur | `AppColors.error` (#EB4040) — hint inline |
| Espacements | `Espacement.paddingBloc`, `Espacement.paddingInput`, `Espacement.radius` |

## 3. Composants UI à créer

### 3.1 Squelette wizard (réutilisables)
- `WizardCircleProgress` — 5 cercles compacts ●●○○○ (filled accent / outlined gray)
- `WizardStepScaffold` — AppBar minimal (back + titre étape + close [×]) + progress + body
- `WizardNavigationBar` — bouton "Continuer ▶" / "Publier ✨" (bottom fixed)
- `WizardAutoSaveIndicator` — petit ✓ silencieux qui apparaît 1s en bas-droite après save

### 3.2 Composants spécifiques
- `AppartementPreviewCard` — carte récap step 5 (photo couverture + titre + adresse + capacité). Réutilisable potentielle dans `mes_appartements.dart`.

### 3.3 Composants à re-styler légèrement
- `RoomsSection` — passer en mode "pills" pour le nombre de chambres (1, 2, 3+) ; conserver steppers pour lits/douches

## 4. Comportements UX

| Cas | Comportement |
|---|---|
| Ouverture wizard (création) | Demande permission GPS → auto-locate → reverse geocode → préremplit step 1 |
| Brouillon existant à l'ouverture | Modal "Reprendre votre brouillon ?" [Reprendre] [Repartir] |
| Ouverture wizard (édition) | Préremplit toutes les étapes ; ouvre sur l'étape demandée si deep-link |
| Auto-save | Debounce 500ms après chaque champ + immédiat à NextStep + `WizardAutoSaveIndicator` flash |
| Close [×] sans publier | `ConfirmDialog` "Reprendre plus tard ?" [Continuer plus tard] [Abandonner] |
| Validation step échoue | Hint inline rouge sous le champ (pas de toast) |
| Étape 5 : récap "manque X" | Hint cliquable qui saute à l'étape concernée |
| Publication réussie | Pop wizard + SnackBar "Votre bien est en ligne 🎉" + draft cleared |

## 5. Maquettes des 5 étapes (récap)

| Étape | Style | Contenu principal |
|---|---|---|
| **1 — Adresse** | Plein écran + bottom sheet | Carte (`LocationPicker`) + adresse texte éditable |
| **2 — Décrire** | Aéré, 1-2 champs | Titre (large input) + type location (sélecteur visuel = `PropertyTypeSection` en pills) |
| **3 — Capacité** | Aéré, 3 sous-sections | Chambres (pills 1/2/3+) + Lits (stepper) + Salles d'eau (stepper) |
| **4 — Photos & équipements** | Plein écran photos + équipements | `ImagesSection` (≥3 photos) + `AmenitiesSection` (chips/pictos) |
| **5 — Prix & publication** | Review Airbnb-like | `AppartementPreviewCard` + `PricingSection` + récap validation |

## 6. Réutilisation des composants existants

| Existant | Réutilisé dans |
|---|---|
| `LocationPicker` | Étape 1 |
| `PropertyTypeSection` | Étape 2 (en sélecteur pills) |
| `RoomsSection` | Étape 3 (avec pills pour chambres) |
| `ImagesSection` + `ImageUploader` | Étape 4 |
| `AmenitiesSection` | Étape 4 |
| `PricingSection` | Étape 5 |
| `DiscountsSection` | Étape 5 (optionnel, replié par défaut) |
| `InputField`, `NumberInputField` | Étape 2, 3, 5 |
| `PlainButton`, `OutlinedCustomButton` | CTA navigation |
| `ConfirmDialog` | Modal reprise / abandon brouillon |
| `Espacement` (constantes) | Tous les écrans |

## 7. Contraintes visuelles à respecter

- ⚠️ **Aucune couleur hors `AppColors`** (règle stricte du projet)
- ⚠️ **Aucun emoji décoratif** dans le code (sauf si demande explicite — ici on a validé `🎉` snackbar et `✨` bouton publier)
- ⚠️ **Espacements via constantes `Espacement`**, pas de magic numbers
- ⚠️ **Toute texte via `TextSeed` widget** (pour cohérence typographique)
- ⚠️ **Mobile-first** : tester sur 360×640 minimum, scroll interne sur step si débord

## 8. Animations

- **Transition step → step** : slide horizontal natif `PageView` (curve `easeInOut`, durée 300ms)
- **AutoSaveIndicator** : fade-in 200ms → hold 800ms → fade-out 200ms
- **Validation error** : shake léger sur le champ invalide (200ms, amplitude 4px)
- **Bouton "Publier"** : passage gris → orange quand `canPublish` devient true (transition 200ms)

## 9. Accessibilité

- Contraste AA respecté (textPrimary sur background = ratio 16:1)
- Steppers : taille tactile minimum 44×44 pt
- Labels explicites pour screen readers
- Indicateur de progression annoncé ("Étape 3 sur 5, Capacité")
