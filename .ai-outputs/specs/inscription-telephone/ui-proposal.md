# Design UI Validé — Inscription simplifiée par téléphone

**Option choisie :** B révisée → **B1** (PIN en cases + clavier dédié, pages séparées, page identité dédiée)

## Parcours visuel (5 écrans)

```
1. Numéro          2. OTP (4 cases)     3. Nom complet      4. Code secret       5. Confirmer
   PhoneInputField    OtpCodeInput         InputField           5 cellules ●         5 cellules ●
   clavier système    clavier système      clavier système      PinKeypad dédié      PinKeypad dédié
```

Règle structurante : **une page = une saisie = un clavier**. Jamais de champ
texte (clavier système) sur les pages à clavier dédié.

## Placement

Tous les écrans reprennent le squelette auth existant :
`AuthRadialBackground` → `IconBoutton` retour → eyebrow d'étape → titre
`AppTextStyles.display` 2 lignes (2ᵉ ligne accent) → sous-titre `body` →
contenu → CTA `CustomButton` lg block.

Eyebrow de progression : `ÉTAPE X/4` (accent, 11px, lettres espacées) —
1 numéro · 2 OTP · 3 nom · 4 code secret (les pages PIN et confirmation
partagent « ÉTAPE 4/4 »).

## Composants à Créer

- **`PinKeypad`** — clavier numérique dédié, grille 3×4 : touches 1-9, 0,
  effacement (icône backspace). Touches rondes/rectangulaires fond `bgElev2`,
  bordure `line`, feedback press accent. Callbacks `onDigit(String)` /
  `onBackspace()`. Réutilisable (futur : verrouillage app, saisie montants).
- **`PinDotsDisplay`** — rangée de 5 cellules 48×56 (même géométrie
  qu'`OtpCodeInput` : fond `bgElev2`, radius `AppRadii.md`, bordure `line`),
  affichant `●` (rempli) ou vide ; cellule « suivante » soulignée accent.
  Pas de TextField — purement affichage, piloté par le clavier.
- **`SignupStepEyebrow`** — petit texte `ÉTAPE X/4` stylé accent.

## Composants à Réutiliser

- `OtpCodeInput` (existant, `length: 4`) — écran OTP, clavier système conservé
- `PhoneInputField`, `InputField`, `CustomButton`, `IconBoutton`,
  `AuthRadialBackground`, `AppTextStyles.display/body/small`

## Maquettes

### Écran 4 — Code secret (et 5 — Confirmation, identique avec titre/CTA propres)

```
┌──────────────────────────────┐
│ ←                            │
│ ÉTAPE 4/4                    │
│ Votre                        │
│ code secret.                 │   ← « Confirmer / votre code. » en écran 5
│ Choisissez 5 chiffres…       │
│                              │
│   [●] [●] [●] [ ] [ ]        │   ← PinDotsDisplay
│                              │
│      1    2    3             │
│      4    5    6             │   ← PinKeypad
│      7    8    9             │
│           0    ⌫             │
│                              │
│ [      Continuer       ]     │   ← actif à 5 chiffres
└──────────────────────────────┘
```

### Écran 3 — Nom complet

```
│ ←                            │
│ ÉTAPE 3/4                    │
│ Comment                      │
│ vous appeler ?               │
│ NOM COMPLET [____________]   │
│ [      Continuer       ]     │
```

## Contraintes Visuelles

- Couleurs : `AppColors.background/bgElev2/line/accent/text/text3/danger` uniquement
- Cellules PIN : mêmes dimensions et états qu'`OtpCodeInput` (cohérence OTP↔PIN)
- Erreur de confirmation : cellules bordées `danger` + message sous la rangée,
  saisie réinitialisée
- Renvoi OTP : lien grisé `text3` pendant cooldown, accent ensuite (pattern actuel)
