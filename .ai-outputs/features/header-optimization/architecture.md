# Architecture : Optimisation de l'espace des en-têtes

## 1. Vue d'ensemble

### Objectif
Réduire l'espace vertical occupé par les en-têtes (headers) dans les écrans principaux de l'application Asfar, en modifiant uniquement les fichiers existants.

### Problèmes identifiés

| Écran | Espace actuel | Problèmes |
|-------|---------------|-----------|
| **Propriétaire** (`proprio_home.dart`) | ~280px | AppBar + GreetingHeader redondants, gap excessif (24px), TabBar séparé |
| **Locataire** (`explore.dart`) | ~240px | AppBar avec info user redondante, recherche + bouton carte sur 2 lignes |

### Objectif cible
- **Propriétaire** : Réduire à ~150px
- **Locataire** : Réduire à ~130px

---

## 2. Modifications proposées

### 2.1 `greeting_header.dart` - Réduire les espacements

**Problème** : Gap de 24px (`gapSection * 2`) entre le titre et le bouton.

**Solution** : Réduire le gap à 8px (`gapSection * 0.5`) ou mettre sur une seule ligne.

```dart
// AVANT (ligne 29)
SizedBox(height: Espacement.gapSection * 2),  // 24px

// APRÈS
SizedBox(height: Espacement.gapItem),  // 4px
```

**OU** layout horizontal :
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    TextSeed("Hi, $userName", ...),
    ElevatedButton.icon(...),
  ],
)
```

---

### 2.2 `proprio_home.dart` - Intégrer TabBar dans AppBar

**Problème** : AppBar + Header + TabBar = 3 niveaux séparés avec gaps.

**Solution** : Intégrer le TabBar dans l'AppBar via `bottom` et supprimer le GreetingHeader.

```dart
// AVANT
appBar: AppBar(
  title: TextSeed("Dashboard Propriétaire"),
  actions: [...],
),
body: Column(
  children: [
    AppartementHeader(...),      // ← SUPPRIMER
    SizedBox(height: 12),        // ← SUPPRIMER
    TabBar(...),                 // ← DÉPLACER dans AppBar
    SizedBox(height: 12),        // ← SUPPRIMER
    Expanded(child: TabBarView(...)),
  ],
)

// APRÈS
appBar: AppBar(
  title: Row(
    children: [
      TextSeed("Hi, ${userName}"),
      Spacer(),
    ],
  ),
  actions: [
    IconButton(icon: Icon(Icons.add), onPressed: onAddListing),  // Bouton Add
    // ... notifications, QR
  ],
  bottom: TabBar(tabs: [...]),  // ← TabBar intégré
),
body: Padding(
  padding: EdgeInsets.all(8),  // Padding réduit
  child: TabBarView(...),
)
```

---

### 2.3 `dynamic_app_bar.dart` - Retirer l'info utilisateur

**Problème** : Affiche nom + avatar de l'utilisateur, redondant avec la page Profil.

**Solution** : Retirer la section utilisateur, garder uniquement le titre.

```dart
// AVANT
actions: [
  BlocConsumer<UserBloc, UserState>(
    builder: (context, state) {
      if (state is UserLoaded) {
        return _buildUserSection(state.user);  // ← SUPPRIMER
      }
      ...
    },
  ),
],

// APRÈS
actions: const [],  // Ou actions personnalisées passées en paramètre
```

---

### 2.4 `explore.dart` - Fusionner recherche et bouton carte

**Problème** : InputSearch et bouton "Vue carte" sur 2 lignes séparées.

**Solution** : Mettre sur une seule ligne avec Row.

```dart
// AVANT
Column(
  children: [
    Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InputSearch(...),
    ),
    Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: PlainButton(value: "Vue carte", ...)),
        ],
      ),
    ),
  ],
)

// APRÈS
Row(
  children: [
    Expanded(child: InputSearch(...)),
    SizedBox(width: 8),
    IconButton(
      icon: Icon(Icons.map_outlined),
      onPressed: () => pushScreen(context, MapExploreScreen()),
    ),
  ],
)
```

---

## 3. Fichiers à modifier

| Fichier | Modification |
|---------|--------------|
| `lib/widget/header/greeting_header.dart` | Réduire gap OU layout horizontal |
| `lib/screen/client/proprio/home/proprio_home.dart` | TabBar dans AppBar, supprimer AppartementHeader |
| `lib/widget/appbar/dynamic_app_bar.dart` | Retirer section utilisateur |
| `lib/screen/client/locataire/home/explore.dart` | Fusionner recherche + bouton carte |

---

## 4. Comparaison Avant/Après

### Propriétaire

```
AVANT (~280px)                      APRÈS (~150px)
┌─────────────────────────┐        ┌─────────────────────────┐
│ Dashboard Propriétaire  │        │ Hi, [nom]    [+][🔔][📷]│
│           [🔔] [📷]     │        │ Réservations | Listings │
├─────────────────────────┤        └─────────────────────────┘
│ Hi, [userName]          │                   ↓
│                         │             [CONTENU]
│ [+ Add new listing]     │
├─────────────────────────┤
│ Réservations | Listings │
└─────────────────────────┘
          ↓
      [CONTENU]
```

### Locataire

```
AVANT (~240px)                      APRÈS (~130px)
┌─────────────────────────┐        ┌─────────────────────────┐
│ Explorer    [Nom][👤]   │        │      Explorer           │
├─────────────────────────┤        ├─────────────────────────┤
│ 🔍 Rechercher...        │        │ 🔍 Rechercher...   [🗺] │
├─────────────────────────┤        └─────────────────────────┘
│ [    Vue carte    ]     │                   ↓
└─────────────────────────┘             [CONTENU]
          ↓
      [CONTENU]
```

---

## 5. Plan d'implémentation

1. **Modifier `greeting_header.dart`** : Réduire le gap ou passer en layout horizontal
2. **Modifier `dynamic_app_bar.dart`** : Retirer la section utilisateur
3. **Modifier `explore.dart`** : Fusionner recherche et bouton carte sur une ligne
4. **Modifier `proprio_home.dart`** : Intégrer TabBar dans AppBar, retirer AppartementHeader

---

## 6. Besoin UI/UX identifié

**OUI** - Validation UI/UX recommandée pour :
- Choix entre GreetingHeader horizontal ou gap réduit
- Position de l'icône carte (droite de la recherche ou dans AppBar)

