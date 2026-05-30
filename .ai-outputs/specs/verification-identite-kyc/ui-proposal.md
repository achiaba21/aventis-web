# 🎨 Design UI Validé — Écran KYC « Vérification d'identité »

> Feature : `verification-identite-kyc`
> Validé par l'utilisateur le 2026-05-30

## Option choisie : **A — Header statut + liste + CTA bas** (upload via bottom sheet)

### Placement
- Nouvel écran `KycScreen` poussé depuis Profil → entrée « Vérification d'identité » (proprio + démarcheur uniquement).
- `Scaffold` fond `AppColors.background` + `DynamicAppBar(title: 'Vérification d'identité')` avec back.
- Structure :
  1. **Header de statut global** (carte) en haut : icône bouclier + libellé « Identité vérifiée » (success) / « En attente de vérification » (warn) / « Identité non vérifiée » (neutral), couleur de fond selon statut (`successLight`/`warningLight`/`bgElev2`).
  2. Eyebrow « MES DOCUMENTS ».
  3. **Liste** (historique complet) de cartes document.
  4. **CTA bas** ancré (hors scroll, `SafeArea`) : `CustomButton` block « Envoyer une pièce » (libellé « Renvoyer une pièce » si le dernier verdict est un refus).
- **États** : chargement → `LoaderCircular` centré ; vide → `EmptyState.hero` (icône `verified_user_outlined`, invite à envoyer, CTA) ; erreur → `EmptyState.error(onRetry)`.

### Flux d'upload (bottom sheet)
- `showModalBottomSheet` (fond `AppColors.background`, `CloseHeader`) → `KycUploadSheet` :
  1. **Sélecteur de titre** (`KycTitleSelector`) : chips/liste prédéfinie — CNI, Passeport, Permis de conduire, Carte consulaire, « Autre ». Si « Autre » → `InputField` libre.
  2. **Source photo** : 2 options galerie / caméra (via `ImagePickerUtil.pickImage`).
  3. **Aperçu** de la photo choisie (Image.file) + possibilité de re-choisir.
  4. **Bouton « Envoyer »** (`CustomButton` block) : désactivé tant que titre + photo non fournis ; spinner pendant l'upload ; ferme la sheet au succès et rafraîchit la liste.

### Composants à Créer
- `kyc_screen.dart` (écran)
- `kyc_status_header.dart` (bandeau statut global)
- `identity_document_card.dart` (carte 1 document : miniature + titre + date + badge + motif si REFUSER)
- `kyc_document_status_badge.dart` (mappe DocumentStatus → BadgeStatus + BadgeTone)
- `kyc_upload_sheet.dart` (bottom sheet)
- `kyc_title_selector.dart` (liste titres + « Autre »)

### Composants à Réutiliser
- `DynamicAppBar`, `BadgeStatus` + `BadgeTone`, `InputField`, `EmptyState` (.hero/.error), `LoaderCircular`, `CustomButton`/`ButtonSize`, `CloseHeader`, `ImagePickerUtil`, `DomainImage`/`Image.network` (miniature via `${domain}/${path}`), thème (`AppColors`/`AppRadii`/`AppTextStyles`).

### Contraintes Visuelles
- Cartes : `bgElev1`, border `line`, radius `AppRadii.md`/`lg`.
- Badges : EN_ATTENTE → `BadgeTone.warn` (« En attente »), VERIFIER → `success` (« Vérifié »), REFUSER → `danger` (« Refusé »).
- Motif de refus : texte `danger`/`text2` sous le badge dans la carte.
- Miniature : carré ~56-64, radius `sm`, `bgElev3` en placeholder/erreur.
- Respect 10 règles Flutter : 1 widget = 1 fichier, pas de fonction privée retournant un Widget, helpers dédiés.
