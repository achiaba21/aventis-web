# 🎨 Propositions UI/UX : Calendrier Intelligent d'Occupation

**Date :** 2026-02-12
**Agent :** UI/UX
**Statut :** En validation

---

## 📊 Analyse UI/UX

### Stack Détecté

- **Framework :** Flutter 3.7.0+
- **Architecture UI :** Widgets réutilisables + BLoC pour réactivité
- **Packages UI :**
  - `gap` : Espacement entre widgets
  - Image carousel custom
  - Composants réutilisables (TextSeed, IconBoutton, CustomButton)

### Design System Observé

**Couleurs :**
- **Primaire :** `#FFA02A` (Orange vif)
- **Background :** `#1D1D1D` (Gris très foncé - Dark theme)
- **Surface :** `#2D2D2D` / `#3D3D3D`
- **Texte :** `#FFFFFF` (primary), `#9E9E9E` (secondary), `#757575` (muted)
- **Calendrier existant :**
  - `calendarReserved` = `#FFA02A` (orange primaire)
  - `calendarBlocked` = `#616161` (gris)
  - `calendarAvailable` = `#4CAF50` (vert)

**Typographie :**
- Police principale : System default
- Tailles : 11-18px (composant TextSeed)
- Poids : normal, w600, bold

**Espacements :**
- `gapItem` : 4px (entre petits éléments)
- `gapSection` : 12px (entre sections)
- `paddingBloc` : 16px (padding standard)
- `radius` : 8px (border radius standard)

**Composants Réutilisables Identifiés :**
- `TextSeed` : Texte stylisé
- `IconBoutton` : Bouton avec icône
- `CustomButton` / `OutlinedCustomButton` : Boutons primaires
- `Gap` : Espacement vertical/horizontal
- `ImageCarousel` : Carousel d'images
- `ListShimmer` : Loader squelette

---

## 🎯 Zones d'Insertion

### Zone 1 : Écran Locataire (AppartDetailScreen)

**Fichier :** `lib/screen/client/locataire/home/appart_detail_screen.dart`

**Structure actuelle :**
```
Scaffold
└── Stack
    └── SingleChildScrollView
        └── Column
            ├── _AppartImageHeader (carousel + boutons)
            └── _AppartDetailContent
                ├── AppartTitreInfo
                ├── AppartProprioInfo
                ├── SejourSelector  ← 🎯 ZONE D'INSERTION
                ├── AppartOffer
                ├── HouseRule
                └── AppartReview
```

**Position optimale :** Après `SejourSelector` ou le remplacer

---

### Zone 2 : Écran Propriétaire (ResidenceDetailScreen)

**Fichier :** `lib/screen/client/proprio/residences/residence_detail_screen.dart`

**Structure actuelle :**
```
Scaffold
└── Column
    ├── Expanded
    │   └── SingleChildScrollView
    │       └── Column
    │           ├── ResidenceInfoSection
    │           ├── "Localisation" (titre)
    │           ├── ResidenceMapSection
    │           │                       ← 🎯 ZONE D'INSERTION
    │           └── _AppartementsSection
    └── _BottomActions
```

**Position optimale :** Après `ResidenceMapSection`, avant `_AppartementsSection`

---

## 💡 Propositions d'Intégration

---

### ✅ Option A : Section Dédiée "Calendrier d'Occupation" (RECOMMANDÉE)

**Description :** Ajouter une section complète avec titre et calendrier dans chaque écran.

#### Pour le Locataire :

**Placement :**
```
┌─────────────────────────────────────────┐
│ 📸 Image Carousel                       │
├─────────────────────────────────────────┤
│ 📝 AppartTitreInfo                      │
│ 👤 AppartProprioInfo                    │
│ 📅 SejourSelector                       │
├─────────────────────────────────────────┤
│ 📆 CALENDRIER D'OCCUPATION  🆕          │
│ ┌─────────────────────────────────────┐ │
│ │ [Février 2026]       ← →            │ │
│ │ L  M  M  J  V  S  D                 │ │
│ │ 1  2  3  4  5  6  7                 │ │
│ │ ▁  ▁  ▁  8  9 10 11                 │ │
│ │     orange (bande fine)             │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ 💰 AppartOffer                          │
│ 📋 HouseRule                            │
│ ⭐ AppartReview                         │
└─────────────────────────────────────────┘
```

#### Pour le Propriétaire :

**Placement :**
```
┌─────────────────────────────────────────┐
│ ℹ️ ResidenceInfoSection                 │
│ 📍 Localisation                         │
│ 🗺️ ResidenceMapSection                  │
├─────────────────────────────────────────┤
│ 📆 CALENDRIER D'OCCUPATION  🆕          │
│ ┌─────────────────────────────────────┐ │
│ │ [Février 2026]       ← →            │ │
│ │ L  M  M  J  V  S  D                 │ │
│ │ 1  2  3  4  5  6  7                 │ │
│ │ ▁  ▁  ▁  8  9 10 11                 │ │
│ │ rouge bleu (multi-bandes)           │ │
│ │                                     │ │
│ │ Légende:                            │ │
│ │ ▁ Appt A1  ▁ Appt A2  ▁ Appt A3    │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ 🏠 Appartements (liste)                 │
└─────────────────────────────────────────┘
```

#### Composants à Créer :

```dart
// Widget principal
OccupationCalendar(
  mode: OccupationCalendarMode.apartment, // ou .residence
  appartementId: appart.id,              // Pour locataire
  residenceId: residence.id,              // Pour proprio (optionnel)
  isInteractive: true,                    // Proprio peut cliquer
)

// Widgets enfants
OccupationDayCell   // Cellule de jour avec bandes
OccupationLegend    // Légende des couleurs (proprio uniquement)
```

#### Réutilisation :

- ✅ `TextSeed` pour titres et légende
- ✅ `Gap(Espacement.gapSection)` pour espacements
- ✅ `Style.surfaceColor` pour fond du calendrier
- ✅ `IconButton` pour navigation mois ← →
- ✅ Pattern de structure similaire à `AvailabilityCalendar`

#### Avantages :

- ✅ **Visibilité maximale** : Section dédiée bien visible
- ✅ **Cohérence** : Même pattern que les autres sections
- ✅ **Évolutivité** : Facile d'ajouter des options (toggle légende, etc.)
- ✅ **Accessibilité** : Titre clair "Calendrier d'Occupation"

#### Inconvénients :

- ⚠️ Augmente légèrement la longueur de scroll
- ⚠️ Nécessite un titre supplémentaire

---

### Option B : Onglet Dédié (Proprio uniquement)

**Description :** Ajouter un système d'onglets dans `ResidenceDetailScreen` (Informations / Calendrier / Appartements).

**Placement :**
```
┌─────────────────────────────────────────┐
│ Détail résidence                        │
├─────────────────────────────────────────┤
│ [Infos] [Calendrier] [Appartements] 🆕 │
├─────────────────────────────────────────┤
│                                         │
│ (Contenu de l'onglet sélectionné)      │
│                                         │
│ Si "Calendrier" sélectionné:           │
│ ┌─────────────────────────────────────┐ │
│ │ [Février 2026]       ← →            │ │
│ │ L  M  M  J  V  S  D                 │ │
│ │ Calendrier pleine page              │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

#### Composants à Créer :

```dart
TabBar / TabBarView
OccupationCalendar (pleine page)
```

#### Réutilisation :

- ✅ `TabBar` / `TabBarView` (Flutter standard)
- ✅ `Style.primaryColor` pour onglet actif
- ✅ Calendrier identique à Option A

#### Avantages :

- ✅ **Calendrier pleine largeur** : Plus d'espace pour afficher
- ✅ **Organisation claire** : Sépare infos / calendrier / appats
- ✅ **Pas de scroll** : Contenu organisé par onglet

#### Inconvénients :

- ⚠️ **Uniquement pour proprio** : Difficile pour locataire (1 seul appart)
- ⚠️ **Friction UX** : Utilisateur doit cliquer sur onglet
- ⚠️ **Refactoring important** : Restructurer complètement l'écran

---

### Option C : Bottom Sheet / Modal

**Description :** Ajouter un bouton "Voir calendrier d'occupation" qui ouvre un bottom sheet.

**Placement (Locataire) :**
```
┌─────────────────────────────────────────┐
│ AppartTitreInfo                         │
│ AppartProprioInfo                       │
│ SejourSelector                          │
│ ┌─────────────────────────────────────┐ │
│ │ 📆 Voir calendrier d'occupation     │ │ 🆕 (bouton)
│ └─────────────────────────────────────┘ │
│ AppartOffer                             │
└─────────────────────────────────────────┘
```

**Au clic → Bottom Sheet :**
```
┌─────────────────────────────────────────┐
│ Calendrier d'Occupation        [X]      │
├─────────────────────────────────────────┤
│ [Février 2026]       ← →                │
│ L  M  M  J  V  S  D                     │
│ 1  2  3  4  5  6  7                     │
│ ▁  ▁  ▁  8  9 10 11                     │
│                                         │
└─────────────────────────────────────────┘
```

#### Composants à Créer :

```dart
OutlinedCustomButton("Voir calendrier") // Bouton
showModalBottomSheet() // Bottom sheet
OccupationCalendar (dans modal)
```

#### Réutilisation :

- ✅ `OutlinedCustomButton` (existe déjà)
- ✅ `showModalBottomSheet` (Flutter standard)
- ✅ Calendrier identique

#### Avantages :

- ✅ **Pas de pollution visuelle** : Caché par défaut
- ✅ **Focus total** : Bottom sheet = pleine attention
- ✅ **Facile à ajouter** : Minimal impact sur layout existant

#### Inconvénients :

- ⚠️ **Friction UX** : Utilisateur doit cliquer pour voir
- ⚠️ **Moins visible** : Peut être raté par certains utilisateurs
- ⚠️ **Étape supplémentaire** : Clic requis

---

## 📋 Comparaison des Options

| Critère | Option A (Section) | Option B (Onglet) | Option C (Modal) |
|---------|-------------------|-------------------|------------------|
| **Visibilité** | ⭐⭐⭐ Excellente | ⭐⭐ Bonne | ⭐ Moyenne |
| **Accessibilité** | ⭐⭐⭐ Directe | ⭐⭐ 1 clic | ⭐ 1 clic |
| **Impact layout** | ⭐⭐ Modéré | ⭐ Fort | ⭐⭐⭐ Minimal |
| **Cohérence** | ⭐⭐⭐ Parfaite | ⭐⭐ Nouvelle UX | ⭐⭐ Bon |
| **Facilité impl.** | ⭐⭐⭐ Simple | ⭐ Complexe | ⭐⭐⭐ Simple |
| **Locataire** | ✅ Adapté | ⚠️ Trop complexe | ✅ Adapté |
| **Propriétaire** | ✅ Adapté | ✅ Très adapté | ✅ Adapté |

---

## 🎨 Maquettes Visuelles

### Option A - Rendu Locataire (Dark Theme)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  📆 Calendrier d'Occupation                            │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │                                                   │ │
│  │    < Février 2026 >                               │ │
│  │                                                   │ │
│  │    L   M   M   J   V   S   D                      │ │
│  │   ──────────────────────────────                  │ │
│  │         1   2   3   4   5   6   7                 │ │
│  │         ▁       ▁               (bande orange)    │ │
│  │    8   9  10  11  12  13  14                      │ │
│  │   ▁▁▁                       (jours occupés)       │ │
│  │   15  16  17  18  19  20  21                      │ │
│  │                                                   │ │
│  │   22  23  24  25  26  27  28                      │ │
│  │                                                   │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  💡 Les dates colorées sont déjà réservées             │
│                                                         │
└─────────────────────────────────────────────────────────┘

Couleurs :
- Background calendrier : #2D2D2D (surfaceColor)
- Bande occupée : #FFA02A (orange - couleur aléatoire)
- Texte jours : #FFFFFF
- Jours passés : #757575 (textMuted)
```

### Option A - Rendu Propriétaire (Multi-appartements)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  📆 Calendrier d'Occupation - Résidence Les Palmiers   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │                                                   │ │
│  │    < Février 2026 >                               │ │
│  │                                                   │ │
│  │    L   M   M   J   V   S   D                      │ │
│  │   ──────────────────────────────                  │ │
│  │         1   2   3   4   5   6   7                 │ │
│  │        ▁▁  ▁▁      ▁▁              (2 appats)     │ │
│  │    8   9  10  11  12  13  14                      │ │
│  │   ▁▁▁▁▁▁                           (multi-bandes) │ │
│  │   15  16  17  18  19  20  21                      │ │
│  │                  ▁▁▁▁▁             (1 appat)      │ │
│  │   22  23  24  25  26  27  28                      │ │
│  │                                                   │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  📊 Légende :                                          │
│  ▁ Appt A1    ▁ Appt A2    ▁ Appt A3                  │
│                                                         │
│  💡 Cliquez sur un jour pour voir les détails          │
│                                                         │
└─────────────────────────────────────────────────────────┘

Couleurs (exemples) :
- Appt A1 : #FF5252 (rouge)
- Appt A2 : #448AFF (bleu)
- Appt A3 : #69F0AE (vert)
```

---

## 🎯 Recommandation

**Option A - Section Dédiée** est recommandée pour les raisons suivantes :

1. ✅ **Visibilité immédiate** : Pas de clic requis
2. ✅ **Cohérence** : S'intègre naturellement dans le scroll existant
3. ✅ **Simplicité** : Implémentation directe sans refactoring
4. ✅ **Adapté aux 2 rôles** : Fonctionne pour locataire ET propriétaire
5. ✅ **Évolutivité** : Facile d'ajouter options/filtres plus tard

---

## 📝 Détails Techniques Option A

### Intégration Locataire

**Fichier :** `lib/screen/client/locataire/home/appart_detail_screen.dart`

**Modification dans `_AppartDetailContent` :**

```dart
class _AppartDetailContent extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppartTitreInfo(appartement: appartement),
          Gap(Espacement.gapSection),
          AppartProprioInfo(proprietaire: appartement.residence?.proprio),
          Gap(Espacement.gapSection),
          SejourSelector(appartement: appartement),

          // 🆕 NOUVEAU : Calendrier d'occupation
          Gap(Espacement.gapSection * 2),
          TextSeed(
            "Calendrier d'Occupation",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Style.foregroundColor,
          ),
          Gap(Espacement.gapSection),
          OccupationCalendar(
            mode: OccupationCalendarMode.apartment,
            appartementId: appartement.id,
            isInteractive: false, // Locataire ne peut pas cliquer
          ),

          Gap(Espacement.gapSection * 2),
          AppartOffer(appartement: appartement),
          // ... reste du code
        ],
      ),
    );
  }
}
```

### Intégration Propriétaire

**Fichier :** `lib/screen/client/proprio/residences/residence_detail_screen.dart`

**Modification dans le `SingleChildScrollView` :**

```dart
SingleChildScrollView(
  padding: EdgeInsets.all(Espacement.paddingBloc),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ResidenceInfoSection(residence: currentResidence),
      SizedBox(height: Espacement.gapSection * 2),

      TextSeed(
        "Localisation",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Style.foregroundColor,
      ),
      SizedBox(height: Espacement.gapSection),
      ResidenceMapSection(
        residence: currentResidence,
        isOwner: true,
        onEditLocation: () { /* ... */ },
      ),

      // 🆕 NOUVEAU : Calendrier d'occupation
      SizedBox(height: Espacement.gapSection * 2),
      TextSeed(
        "Calendrier d'Occupation",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Style.foregroundColor,
      ),
      SizedBox(height: Espacement.gapSection),
      OccupationCalendar(
        mode: OccupationCalendarMode.residence,
        residenceId: currentResidence.id,
        isInteractive: true, // Proprio peut cliquer
        onPeriodTap: (reservationId) {
          // Naviguer vers détails réservation
          _showReservationDetails(context, reservationId);
        },
      ),

      SizedBox(height: Espacement.gapSection * 2),
      _AppartementsSection(
        residenceId: currentResidence.id,
      ),
      // ... reste du code
    ],
  ),
)
```

---

## ✅ Checklist Validation

- [x] Design cohérent avec l'existant (dark theme, orange primaire)
- [x] Réutilise composants existants (TextSeed, Gap, Style.*)
- [x] S'intègre naturellement dans le layout
- [x] Adapté aux deux rôles (locataire / propriétaire)
- [x] Pas de refactoring majeur requis
- [x] Évolutif (possibilité d'ajouter options)
- [x] Respecte les espacements standard

---

**Document prêt pour validation utilisateur.**
