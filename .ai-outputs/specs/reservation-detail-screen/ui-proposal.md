# 🎨 Design UI Validé : Page Détail Réservation

> **Feature :** `reservation-detail-screen`
> **Date :** 2026-05-12
> **Option choisie :** **A — Ticket de voyage** + 4 enrichissements
> **Statut :** ✅ Validée par utilisateur

---

## 1. Placement

**Nouveau dossier transverse** : `lib/screen/client/shared/reservations/`
- Cohérent avec `shared/partenariats/` (pattern similaire)
- Ouverte par 6 points d'entrée existants (trips, liste proprio, dashboard, referrals, card chat, push notif)

**Pattern de référence à reproduire :**
- Layout général : `PartenariatDetailScreen` (Scaffold + AppBar dark + SingleChildScrollView)
- Hero : `BeneficeNetHeroCard` (gradient or, eyebrow nav, montant mono)
- Party cards : `PartenariatDetailPartyCard` (avatar + nom + tel + bouton phone)

---

## 2. Layout général

```
Scaffold backgroundColor: AppColors.background
├── DynamicAppBar(title: 'Détail réservation', leading: IconBoutton(arrow_back))
├── SafeArea top:false
│   └── SingleChildScrollView padding(18, 18, 18, 96)  ← 96 = espace pour sticky bottom
│       └── Column crossAxis: start
│           ├── ReservationDetailHeader        (hero gradient)
│           ├── SizedBox(24)
│           ├── Text 'LOGEMENT' (eyebrow)
│           ├── SizedBox(10)
│           ├── ReservationDetailAppartCard
│           ├── SizedBox(24)
│           ├── Text 'MONTANTS' (eyebrow)
│           ├── SizedBox(10)
│           ├── ReservationDetailAmountsSection
│           ├── SizedBox(24)
│           ├── Text 'PROPRIÉTAIRE' (eyebrow)  ← libellé selon rôle
│           ├── SizedBox(10)
│           ├── ReservationDetailPartyCard
│           ├── SizedBox(24)
│           ├── [if proprio + démarcheur] ReservationDetailDemarcheurCard
│           ├── SizedBox(24)
│           ├── [if locataire + statut≥payee] ReservationDetailQrSection
│           ├── SizedBox(24)
│           ├── Text 'HISTORIQUE' (eyebrow)
│           ├── SizedBox(10)
│           └── ReservationDetailTimeline
└── bottomNavigationBar: ReservationDetailActionsBar  ← STICKY
```

**Espacement** : 24px entre sections (cohérent avec partenariat detail), 10px entre eyebrow et contenu.
**Padding global** : 18px horizontal (cohérent avec partenariat).
**Padding bottom du scroll** : 96px pour laisser de la place à l'action bar sticky.

---

## 3. Composants à créer (détaillés)

### 3.1 ReservationDetailHeader (hero gradient or)

```dart
Container
  width: double.infinity
  padding: EdgeInsets.all(20)
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.heroGradientGold,   ← REUSE existant
      begin: topLeft, end: bottomRight,
    )
    borderRadius: BorderRadius.circular(AppRadii.lg)
    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))
  )
  child: Column(crossAxis: start) [
    Row [
      Text 'RÉSERVATION · ASF-7K2N9' (eyebrow + accent fg)
      Spacer
      Text '🌐 Plateforme' (chip small)  ← icône du ReservationType
    ],
    SizedBox(14),
    Text 'FcfaFormatter.full(prix)' (mono, h1 30px, color: text),
    SizedBox(8),
    Row [
      BadgeStatus(text: 'PAYÉE', tone: success)  ← REUSE
      SizedBox(8),
      Text ' · 3 nuits · 12-15 mai 2026' (small, text2)
    ]
  ]
```

**Visuel attendu** : signature or chaud, montant en grand, statut bien visible. Évoque un ticket premium.

### 3.2 ReservationDetailAppartCard (logement cliquable)

Card `bgElev1` + `border line` + radius `md` + onTap → push fiche appart.
- ImgPlaceholder tone (52×52) à gauche
- Column titre `h3` + adresse `small text3` à droite
- Icon `chevron_right` à droite tone `text3`

### 3.3 ReservationDetailAmountsSection (clé/val)

Card `bgElev1` avec lignes :
```
Prix total            65 000 F     ← Row avec mono
Frais Asfar (6%)       3 900 F
Avance versée        −20 000 F
────────────────────────────         ← Divider line
Reste à payer         48 900 F     ← Row avec mono + color: accent (or)
```

Hiérarchie : ligne « Reste à payer » en couleur accent or pour la mettre en valeur (emprunt à C — montant à payer = info critique).

### 3.4 ReservationDetailPartyCard (locataire/proprio/client externe)

**Clone de `PartenariatDetailPartyCard`** avec adaptation :
- Avatar gradient avec initiale (`avatarGradientStart` → `avatarGradientEnd`)
- Column [eyebrow `role` + nom h3 + téléphone mono small]
- IconBoutton phone (or) à droite, disabled si pas de tel
- Pour résa manuelle : afficher `clientExterneNom` + `clientExterneTelephone` à la place du locataire

### 3.5 ReservationDetailDemarcheurCard (proprio + résa démarcheur)

Identique à PartyCard mais avec **info commission** sous le nom :
```
DÉMARCHEUR SOURCE
Diallo K.
+225 07 99 12 34
─────────────────
Commission convenue : 2 500 F     ← BadgeStatus tone accent
```

### 3.6 ReservationDetailQrSection (locataire + statut ≥ payee)

```dart
Container
  padding: EdgeInsets.all(20)
  decoration: BoxDecoration(
    gradient: RadialGradient(           ← Halo or signature Asfar (✅ enrichissement)
      colors: [AppColors.accentSoft, transparent],
      radius: 0.8,
    )
    borderRadius: BorderRadius.circular(AppRadii.lg)
    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))
  )
  child: Column(crossAxis: center) [
    Container(                          ← QR sur fond clair pour contraste scan
      padding: 16,
      decoration: BoxDecoration(
        color: AppColors.white,         ← inversion locale autorisée pour QR
        borderRadius: AppRadii.md,
      ),
      child: QrImageView(
        data: codeReservation.secretKey,
        size: 220,
        backgroundColor: white,
        eyeStyle: QrEyeStyle(color: AppColors.black),
        dataModuleStyle: QrDataModuleStyle(color: AppColors.black),
      )
    ),
    SizedBox(12),
    Text 'ASF-7K2N9' (mono, h3, color: text),
    SizedBox(4),
    Text 'Présentez ce code à l\'arrivée' (small, text2)
  ]
```

**Halo or radial** subtil derrière le QR (emprunt à l'enrichissement validé) = signature Asfar.

### 3.7 ReservationDetailTimeline (stepper vertical)

```dart
Container bgElev1 + border line + padding 16
  Column [
    ReservationDetailTimelineRow (dot, label, date, isLast: false, isPassed: true)
    ...
  ]
```

**ReservationDetailTimelineRow** :
```
●─── Créée                3 mai 2026
│
●─── Confirmée            5 mai 2026
│
●─── Payée                7 mai 2026
```

- Dot 10×10 cercle plein couleur `tone` (✅ enrichissement « couleurs sémantiques ») :
  - vert (success) pour `created`, `confirmed`, `paid`, `finalized`, `terminated`
  - rouge (danger) pour `refused`, `cancelled`
  - gris (textDim) pour étapes futures non franchies
- Trait vertical 1px `line` entre les dots
- Texte label `body 14`, date `small text3` à droite mono

### 3.8 ReservationDetailActionsBar (sticky bottom)

```dart
BottomAppBar (ou Container ancré via bottomNavigationBar):
  Container
    padding: EdgeInsets.fromLTRB(18, 12, 18, 18+safeArea)
    decoration: BoxDecoration(
      color: AppColors.bgElev1,
      border: Border(top: BorderSide(color: AppColors.line))
    )
    child: Row [
      Expanded(CustomButton.primary('Action principale', onPressed))  ← Premier de la liste
      SizedBox(10)
      IconBoutton(phone, accent)                                       ← Toujours visible si "Contacter"
      [Si autres actions:] PopupMenuButton(...)                        ← Overflow
    ]
```

**Logique** : prend la première action de `ReservationActionsResolver.actionsFor(role, reservation)` en primary, met `Contacter` en icon button dédié, le reste en overflow `⋯`. Si 1 seule action → bouton pleine largeur.

### 3.9 ReservationDetailLoadingView (skeleton structuré) ✅ enrichissement

Reproduit la structure réelle avec des Containers gris `bgElev2` :
```
Hero gris (180h)
SizedBox(24)
Skeleton eyebrow (60×11)
Skeleton card (72h)
... (toutes les sections)
```

Mieux que `shimmer_card` générique : l'utilisateur voit la structure se charger, perception de vitesse améliorée.

### 3.10 ReservationDetailErrorView

`EmptyState` (REUSE existant) avec :
- Icon `error_outline` taille 64
- Titre h3 « Réservation introuvable »
- Sub small text2 (message)
- CustomButton outlined « Réessayer » → `bloc.add(RefreshFromApi())`

### 3.11 ReservationContactSheet (bottom sheet) ✅ enrichissement

`showModalBottomSheet` avec `backgroundColor: bgElev1` :
```
ContactSheet:
  Drag handle (40×4 textDim)
  Padding(20)
  Column [
    Text 'CONTACTER' (eyebrow)
    SizedBox(10)
    Text nom (h3),
    SizedBox(16),
    [Si tel] PaymentMethodTile-style (icon phone or) 'Appeler +225...' → tel:
    SizedBox(8)
    [Si userId] PaymentMethodTile-style (icon chat or) 'Discuter dans Asfar' → push conversation
    SizedBox(16+safeArea)
  ]
```

---

## 4. Composants à réutiliser (zéro nouveau atomique)

| Existant | Usage |
|----------|-------|
| `DynamicAppBar` | En-tête de page |
| `IconBoutton(Icons.arrow_back_ios_new)` | Retour |
| `BadgeStatus` + `BadgeTone` | Statut visuel partout |
| `ReservationStatusDisplay` (déplacé) | Mapping statut → label + tone |
| `CustomButton` (primary or) | Bouton primaire action bar |
| `OutlinedCustomButton` | Boutons secondaires (Annuler, Refuser) |
| `IconBoutton` | Phone, chat, overflow |
| `ImgPlaceholder` | Image appart avec tone |
| `AsfarChip` | Chip type (plateforme/manuelle/démarcheur) |
| `EmptyState` | Vue erreur |
| `InfoBanner` | Bandeau "mode hors ligne" si applicable |
| `FcfaFormatter` | Tous les montants |
| Hero gradient `heroGradientGold` | Background du header |
| `AppColors.avatarGradientStart/End` | Avatar party card |

---

## 5. Contraintes visuelles

### Couleurs (strictement depuis `AppColors`)
- Fond écran : `background` (#0A0A0B)
- Cards : `bgElev1` (#131316) + `border: line` (#14FFFFFF)
- QR : **inversion locale autorisée** — fond `white`, modules `black` (lisibilité scanner)
- Halo QR : `accentSoft` (or 14%) en radial gradient
- Hero : `heroGradientGold` (existant)
- Reste à payer : couleur `accent` (or) pour valoriser
- Dots timeline : `success`/`danger`/`textDim` selon état (✅ enrichissement)

### Typographie
- Référence (`ASF-XXXXX`) : `mono(h3)` partout (tabular figures)
- Montants : `mono(...)` partout (alignement chiffres)
- Eyebrows : `AppTextStyles.eyebrow` (11px uppercase, letterSpacing 1.2)
- Titres sections : pas de h2, juste eyebrow puis contenu

### Espacements
- 24px entre sections
- 10px entre eyebrow et contenu
- 16-18px padding interne des cards
- 20px padding du hero (un peu plus généreux)

### Animations
- Pas de transition d'entrée custom (laisser `MaterialPageRoute` standard)
- Spinner action en cours : `CircularProgressIndicator(color: accent)` dans le bouton (remplace le label)
- Skeleton : pas de shimmer, juste des Containers gris fixes (sobre, cohérent dark theme)

---

## 6. Variantes par rôle (résumé visuel)

### 👤 Locataire (résa plateforme)
- Hero : 🌐 Plateforme, statut tone success/warn selon
- Sections visibles : Logement, Montants, **Propriétaire**, QR (si ≥payée), Timeline
- Action bar : selon matrice (Annuler / Payer / Voir code)

### 🏠 Propriétaire (résa plateforme/démarcheur)
- Hero : 🌐 ou 🤝 selon type, statut
- Sections : Logement, Montants, **Client/Locataire**, **Démarcheur** (si démarcheur), Timeline
- Pas de QR (c'est le scanner qui l'utilise)
- Action bar : Confirmer/Refuser/Scanner/Contacter

### 🏠 Propriétaire (résa manuelle)
- Hero : 📝 Manuelle, statut
- Sections : Logement, Montants (**pas de frais Asfar**), **Client externe** (nom/tel/email), Timeline
- Action bar : Éditer (si statut < payée) / Annuler / Scanner / Contacter

### 🤝 Démarcheur (résa qu'il a apportée)
- Hero : 🤝 Démarcheur, statut
- Sections : Logement, Montants (**avec sa commission mise en valeur**), **Propriétaire**, **Client**, Timeline
- Pas de QR
- Action bar : juste Contacter (proprio)

---

## 7. États visuels couverts

| État | Rendu |
|------|-------|
| Loading initial | `ReservationDetailLoadingView` (skeleton structuré) |
| Loaded fresh | Page complète |
| Loaded stale (cache) | Page + `InfoBanner` discret « Synchronisation… » en haut |
| Refreshing en arrière-plan | Indicator subtil dans l'AppBar (3px linear) |
| Action en cours | Bouton primaire avec spinner + autres actions désactivées |
| Erreur chargement | `ReservationDetailErrorView` (EmptyState + retry) |
| Mode offline + cache vide | EmptyState « Pas de connexion » |

---

## 8. Notes d'implémentation pour l'agent Dev

- **Inversion locale dark→light** pour le QR : utiliser `Theme(data: ThemeData.light(), child: QrImageView(...))` localement OU passer explicitement `backgroundColor: white` + `dataModuleStyle/eyeStyle` couleur black. Vérifier que le rendu reste lisible sur 220×220.
- **Halo radial autour QR** : `RadialGradient` dans `decoration` du container parent, pas un widget séparé (KISS).
- **AppBar avec ref optionnel** (emprunt à C) : titre = 'Détail réservation', possibilité d'ajouter un menu `⋯` plus tard pour « Copier la référence ». Hors scope V1.
- **Bottom sheet contact** : suit le pattern de `ExportBottomSheet` (recently created in finances), même style drag handle + padding.
- **Liberté d'arbitrage** : si pendant l'implémentation un élément des options B ou C s'avère meilleur (ex. AppBar avec ref si gain UX clair, ou clé/val sur 2 colonnes serrées si écran trop long), l'autorisation est donnée — sans casser le squelette « hero + sections + sticky bottom ».
