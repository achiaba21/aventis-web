# Design UI Validé — Refonte Flux Inscription

**Option choisie : A — Cartes Empilées Pleines**

## RoleSelectionScreen

- Fond : `Style.containerColor3` (#1D1D1D) avec watermark logo (opacity 0.1, repeat)
- Logo centré en haut
- Titre : "Qui êtes-vous ?" — TextSeed, bold
- 3 cartes empilées, chacune : fond `#2D2D2D`, border radius 8, bord gauche 4px coloré
  - Locataire  → bord `Style.primaryColor` (orange), icône 🏠 `Icons.home_outlined`
  - Propriétaire → bord `Style.containerColor` (violet), icône 🏢 `Icons.apartment_outlined`
  - Démarcheur → bord `Style.successColor` (vert), icône 🤝 `Icons.handshake_outlined`
- Chaque carte : icône + titre bold + sous-titre gris (`Style.textSecondary`)
- Tap sur une carte → navigation vers SignupScreen(role)

## SignupScreen

- Fond : `Style.containerColor3` avec watermark logo (identique au LoginForm existant)
- Logo centré en haut
- Titre : "Créer un compte" + badge rôle sélectionné (primaryColor)
- Bouton retour (AppBar transparent ou back icon)
- 3 champs :
  1. `InputField` — Nom complet, `Icons.person_outline`
  2. `PhoneInputField` — Téléphone avec sélecteur de pays
  3. `InputPass` — Mot de passe, `keyboardType: TextInputType.number`, `maxLength: 5`
- `CustomButton` plein largeur — "Continuer"
- Validation : champs non vides, mdp exactement 5 chiffres

## OtpVerificationScreen

- Fond : `Style.containerColor3`
- Logo + titre "Vérification" + sous-titre avec numéro masqué (ex: +225 ••• ••• 42)
- Widget `OtpInput` : 4 cases carrées (60x60), fond `#2A2A2A`, border radius 8
  - Border normal : transparent
  - Border focus : `Style.primaryColor` 2px
  - Border rempli : `Style.primaryColor` 1px
  - Texte : blanc, fontSize 24, bold
- Message d'erreur en rouge sous les cases (tentatives restantes)
- Blocage à 5 tentatives : cases grises, message "Compte bloqué"
- Bouton "Renvoyer le code" :
  - Pendant délai : grisé, affiche "Renvoyer dans Xs"
  - Disponible : `TexteButton` orange
  - Délais progressifs : [15, 20, 30, 60]s

## Composants à Créer

- `OtpInput` widget — `lib/widget/input/otp_input.dart`

## Composants à Réutiliser

- `Logo` — logo en haut de chaque écran
- `TextSeed` — tous les textes
- `InputField` — champ nom complet
- `PhoneInputField` — champ téléphone
- `InputPass` — champ mot de passe (adapté 5 chiffres numériques)
- `CustomButton` — bouton principal
- `TexteButton` — bouton renvoyer OTP
- `Espacement.*` — tous les espacements

## Contraintes Visuelles

- Thème sombre partout : background #1D1D1D, inputs #2A2A2A, cards #2D2D2D
- Primary color orange (#FFA02A) pour focus, actions, accents
- Border radius uniforme : 8px
- Watermark logo (opacity 0.1) sur RoleSelection et Signup (cohérent avec LoginForm)
- Pas de nouvelles couleurs introduites
