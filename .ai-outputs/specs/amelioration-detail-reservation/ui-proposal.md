# Spécification UI/UX - Amélioration Interface Détail & Réservation

## Option Validée : B - Accent Succès (modifiée)

---

## 1. Palette de Couleurs

### Couleurs existantes (inchangées)
```dart
primaryColor = #FFA02A      // Orange
backgroundColor = #1D1D1D   // Fond dark
foregroundColor = #FFFFFF   // Texte blanc
errorColor = #EB4040        // Rouge erreur
```

### Nouvelles couleurs à ajouter
```dart
successColor = #4CAF50      // Vert pour économies
surfaceColor = #2D2D2D      // Fond des cards (plus clair que background)
surfaceColorLight = #3D3D3D // Fond surligné (ligne active)
textSecondary = #9E9E9E     // Texte secondaire
textMuted = #757575         // Texte désactivé

// Calendrier
calendarBlocked = #616161   // Dates bloquées (gris)
calendarReserved = primaryColor  // Dates réservées (orange)
```

---

## 2. Layout AppartDetailScreen (Locataire)

### Ordre des sections (modifié)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │              [CAROUSEL PHOTOS]                      │   │
│  │                  300px height                       │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Studio Cocody - 2 chambres                         │   │
│  │  ⭐ 4.8 (12 avis)  •  2 🛏️  •  1 🚿               │   │
│  │                                                     │   │
│  │  10 000 F / nuit                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🏷️ Réductions pour séjours prolongés              │   │
│  │                                                     │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │  7+ jours      8 000 F/nuit         -10%     │ │   │
│  │  │  fond: #2D2D2D                               │ │   │
│  │  └───────────────────────────────────────────────┘ │   │
│  │                                                     │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │  30+ jours     7 000 F/nuit     ✓  -20%     │ │   │
│  │  │  fond: #3D3D3D  bordure: #FFA02A  (ACTIF)   │ │   │
│  │  └───────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Description                                        │   │
│  │                                                     │   │
│  │  "Magnifique studio situé au cœur de Cocody..."    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📍 Localisation                                    │   │
│  │                                                     │   │
│  │  ┌───────────────────────────────────────────────┐ │   │
│  │  │                                               │ │   │
│  │  │         [CARTE ZONE APPROXIMATIVE]            │ │   │
│  │  │              height: 200px                    │ │   │
│  │  │                                               │ │   │
│  │  │         "Cocody, Abidjan"                     │ │   │
│  │  │      Localisation approximative               │ │   │
│  │  │                                               │ │   │
│  │  └───────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🛋️ Commodités                                      │   │
│  │                                                     │   │
│  │  [WiFi] [Climatisation] [Cuisine] [Parking]        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ⭐ Avis (12)                                       │   │
│  │                                                     │   │
│  │  [Liste des avis...]                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📅 Sélectionnez vos dates                          │   │
│  │                                                     │   │
│  │  [Calendrier de sélection]                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  📜 Règles de la maison                             │   │
│  │                                                     │   │
│  │  • Pas de fête                                      │   │
│  │  • Pas de fumée                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [Espace pour bottom bar]                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  BOTTOM BAR (fixe)                                          │
│                                                             │
│  8 000 F/nuit  1̶0̶ ̶0̶0̶0̶ ̶F̶  (-20%)                          │
│  Total : 56 000 F                                           │
│  ✓ Économisez 14 000 F          [ Réserver ]               │
│     (vert #4CAF50)                (orange)                  │
│  15 jan - 22 jan                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Sections supprimées
- ❌ **Info Propriétaire** : Supprimé de la page détail appartement

---

## 3. Design RemiseInfo (modifié)

### Avant (problème)
- 4 couleurs différentes : vert, teal, bleu, indigo
- Gradients multicolores
- Incohérent avec le design system

### Après (solution)
- Fond `surfaceColor` (#2D2D2D) pour toutes les cards
- Bordure `primaryColor` (#FFA02A) uniquement pour la ligne active
- Fond `surfaceColorLight` (#3D3D3D) pour la ligne active
- Badge pourcentage en `primaryColor`

```
┌──────────────────────────────────────────────────────────┐
│  🏷️ Réductions pour séjours prolongés                   │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │  ┌────────┐                                        │ │
│  │  │  -10%  │   7+ jours  →  8 000 F/nuit           │ │
│  │  └────────┘   au lieu de 10 000 F                 │ │
│  │   (orange)                                         │ │
│  │                                                    │ │
│  │  fond: #2D2D2D  (non actif)                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                            ✓       │ │
│  │  ┌────────┐                                        │ │
│  │  │  -20%  │   30+ jours  →  7 000 F/nuit          │ │
│  │  └────────┘   au lieu de 10 000 F                 │ │
│  │   (orange)                                         │ │
│  │                                                    │ │
│  │  fond: #3D3D3D  bordure: #FFA02A  (ACTIF)         │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 4. Design AppartBottom (modifié)

### Avant (problème)
- Prix réduit affiché mais économie invisible
- Pas de comparaison avant/après

### Après (solution)
- Prix original barré à côté du prix réduit
- Pourcentage de réduction
- Ligne "Économisez X F" en vert (`successColor`)

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Sans réduction :                                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │  10 000 F/nuit                                     │ │
│  │                                     [ Réserver ]   │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Avec réduction (dates sélectionnées) :                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │  8 000 F/nuit  1̶0̶ ̶0̶0̶0̶ ̶F̶  (-20%)                   │ │
│  │  Total : 56 000 F                                  │ │
│  │  ✓ Économisez 14 000 F    (#4CAF50)               │ │
│  │  15 jan - 22 jan                  [ Réserver ]    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 5. Carte Localisation

### Design
- Hauteur : 200px
- Coins arrondis : 12px (Espacement.radius + 4)
- Mode : Zone approximative (pas de marker exact)
- Overlay semi-transparent avec nom du quartier

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  📍 Localisation                                         │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │         [Carte OpenStreetMap - Dark mode]          │ │
│  │                                                    │ │
│  │    ┌────────────────────────────────────────┐     │ │
│  │    │  📍 Cocody, Abidjan                    │     │ │
│  │    │     Localisation approximative         │     │ │
│  │    └────────────────────────────────────────┘     │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 6. Calendrier Propriétaire

### Position
- Après le contenu existant de `ProprioAppartDetailScreen`
- Dans une section "Disponibilités"

### Design
```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  📅 Disponibilités                                       │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         ◀  Janvier 2024  ▶                        │ │
│  │                                                    │ │
│  │   L     M     M     J     V     S     D           │ │
│  │                                                    │ │
│  │   1     2     3     4     5     6     7           │ │
│  │                                                    │ │
│  │   8     9    [10]  [11]  [12]   13    14          │ │
│  │              gris   gris  gris                     │ │
│  │                                                    │ │
│  │   15    16    17    18    19    20    21          │ │
│  │                                                    │ │
│  │   22   [23]  [24]  [25]   26    27    28          │ │
│  │        orange orange orange (réservées)           │ │
│  │                                                    │ │
│  │   29    30    31                                  │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Légende :                                               │
│  ⬜ Disponible   🟧 Réservé (#FFA02A)   ⬛ Bloqué (#616161) │
│                                                          │
│  [ Bloquer des dates ]                                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 7. Récapitulatif des Modifications

### Fichiers à modifier

| Fichier | Modifications UI |
|---------|------------------|
| `remise_info.dart` | Couleurs monochromes, ligne active surlignée |
| `appart_bottom.dart` | Prix barré + économie en vert |
| `appart_detail_content.dart` | Réordonner : Réductions après prix, supprimer Info Proprio |
| `style.dart` | Ajouter successColor, surfaceColor, etc. |

### Composants UI à créer

| Composant | Design |
|-----------|--------|
| `DetailSectionCard` | Fond #2D2D2D, radius 12, padding 16 |
| `AppartMapSection` | Carte 200px, overlay avec nom quartier |
| `AvailabilityCalendar` | Couleurs : gris (bloqué), orange (réservé) |

---

**Statut :** ✅ Validé par l'utilisateur
**Date :** 2026-01-18
