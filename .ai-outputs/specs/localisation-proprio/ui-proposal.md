# Proposition UI/UX : Localisation Proprio

## 1. Analyse Interface Existante

### Stack UI
- **Framework** : Flutter/Dart
- **Thème** : Sombre (Dark mode)
- **CSS/Style** : Custom `Style` class

### Design System Observé

| Propriété | Valeur |
|-----------|--------|
| primaryColor | `#FFA02A` (orange) |
| backgroundColor | `#1D1D1D` (dark) |
| containerColor2 | `#FFFFFF` (white text) |
| Espacement.radius | `8` |
| Espacement.paddingBloc | `16` |
| Espacement.gapSection | `12` |

### Composants Réutilisables

| Composant | Fichier | Réutilisation |
|-----------|---------|---------------|
| `LocationPickerMapScreen` | `lib/screen/map/location_picker_map_screen.dart` | Onglet Carte |
| `LocationPicker` | `lib/widget/form/location_picker.dart` | Pattern GPS + Map |
| `LocationData` | `lib/widget/form/location_picker.dart` | Modèle de données |
| `SensitiveDataPlaceholder` | `lib/widget/sensitive/sensitive_data_placeholder.dart` | Pattern placeholder |
| `GeocodingService` | `lib/service/geocoding/geocoding_service.dart` | Autocomplétion |
| `CustomButton` | `lib/widget/button/custom_button.dart` | Bouton validation |
| `InputField` | `lib/widget/input/input_field.dart` | Champs de saisie |
| `TextSeed` | `lib/widget/text/text_seed.dart` | Texte stylé |

---

## 2. Option Retenue : Bottom Sheet Modal avec Onglets

### Pourquoi cette option ?
- Plus léger qu'un nouvel écran complet
- Navigation rapide entre les 3 méthodes
- Respecte les patterns Flutter/Material modernes
- Permet de garder le contexte de la page détail

### Structure du Bottom Sheet

```
┌─────────────────────────────────────────────────────────────┐
│ ────────                                                    │
│                                                             │
│  Modifier la localisation                              [X]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   [🔍 Recherche]    [🗺️ Carte]    [📝 Manuel]               │
│   ═══════════════                                           │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  CONTENU SELON ONGLET                                       │
│                                                             │
│  Onglet Recherche :                                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🔍 Rechercher une adresse...                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Suggestions :                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 📍 Cocody, Abidjan, Côte d'Ivoire                   │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 📍 Cocody Angré, Abidjan, Côte d'Ivoire             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  Onglet Carte :                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                                                     │    │
│  │                    [CARTE]                          │    │
│  │                                                     │    │
│  │                  📍 (marker)                        │    │
│  │                                                [📍] │    │
│  └─────────────────────────────────────────────────────┘    │
│  Appuyez sur la carte pour sélectionner                     │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  Onglet Manuel :                                            │
│  Latitude                                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 5.393639                                            │    │
│  └─────────────────────────────────────────────────────┘    │
│  Longitude                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ -3.918602                                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Position sélectionnée : 5.393639, -3.918602               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              ✓ Valider la localisation              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. États de ResidenceMapSection

### État 1 : Proprio AVEC coordonnées exactes

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                        [CARTE]                              │
│                                                             │
│                    📍 (marker orange)                       │
│                                                             │
│                                                   ┌───────┐ │
│                                                   │  ✏️   │ │  ← FAB Modifier
│                                                   └───────┘ │
├─────────────────────────────────────────────────────────────┤
│ Coordonnées GPS                                             │
│ Lat: 5.393639, Long: -3.918602                              │
└─────────────────────────────────────────────────────────────┘
```

**Spécifications du FAB "Modifier" :**
- Position : bottom-right, margin 12px
- Taille : 44x44
- Background : `Style.primaryColor` (#FFA02A)
- Icône : `Icons.edit` (blanc)
- Ombre : `MapConfig.fabShadow`

### État 2 : Proprio SANS coordonnées

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│         ┌─────────────────────────────────────────┐         │
│         │                                         │         │
│         │              📍                         │         │
│         │                                         │         │
│         │     Localisation non renseignée         │         │
│         │                                         │         │
│         │     ┌───────────────────────────┐       │         │
│         │     │  ➕ Ajouter               │       │         │
│         │     └───────────────────────────┘       │         │
│         │                                         │         │
│         └─────────────────────────────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Spécifications :**
- Container : `Style.containerColor2` avec opacité 0.1
- Border : `Style.primaryColor` avec opacité 0.3
- Icône : `Icons.location_on`, taille 48, couleur `Style.primaryColor`
- Titre : "Localisation non renseignée", blanc, 16px, semibold
- Bouton : OutlinedButton avec border primaryColor

### État 3 : Locataire (carte approximative)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│               [CARTE CENTRÉE SUR COMMUNE]                   │
│                  (pas de marker précis)                     │
│                                                             │
│         ┌─────────────────────────────────────────┐         │
│         │ 📍 Cocody, Abidjan                      │         │
│         │ Localisation approximative              │         │
│         └─────────────────────────────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Changements par rapport à l'existant :**
- Retirer le bouton/texte "Réserver maintenant"
- Changer "Adresse exacte disponible après paiement" → "Localisation approximative"
- Garder l'overlay semi-transparent
- Désactiver les interactions carte (déjà fait)

---

## 4. Flux d'Interaction

### Proprio ajoute localisation

```
Proprio consulte sa résidence
         │
         ▼
ResidenceMapSection (isOwner=true, hasExactLocation=false)
         │
         ▼
   Affiche placeholder "Ajouter"
         │
         ▼
   Proprio clique "Ajouter"
         │
         ▼
LocationEditBottomSheet.show()
         │
         ▼
   Proprio choisit méthode (Recherche/Carte/Manuel)
         │
         ▼
   Proprio sélectionne/saisit coordonnées
         │
         ▼
   Proprio clique "Valider"
         │
         ▼
   onLocationSaved(LocationData)
         │
         ▼
   API PATCH /residences/{id}/address
         │
         ▼
   Refresh → Affiche carte avec marker
```

### Proprio modifie localisation

```
Proprio consulte sa résidence
         │
         ▼
ResidenceMapSection (isOwner=true, hasExactLocation=true)
         │
         ▼
   Affiche carte + FAB "Modifier"
         │
         ▼
   Proprio clique FAB
         │
         ▼
LocationEditBottomSheet.show(initialAddress: currentAddress)
         │
         ▼
   [Même flux que ci-dessus]
```

---

## 5. Composants à Créer

| Composant | Type | Description |
|-----------|------|-------------|
| `LocationEditBottomSheet` | StatefulWidget | Bottom sheet avec 3 onglets |
| `_SearchTab` | Widget privé | Onglet recherche avec autocomplete |
| `_MapTab` | Widget privé | Onglet carte interactive |
| `_ManualTab` | Widget privé | Onglet saisie manuelle lat/lng |
| `_buildOwnerPlaceholder` | Méthode | Placeholder "Ajouter" dans ResidenceMapSection |

---

## 6. Modifications Existantes

| Fichier | Modification |
|---------|-------------|
| `residence_map_section.dart` | Ajouter `isOwner`, `onEditLocation`, nouveau placeholder, FAB |
| `residence_detail_screen.dart` (proprio) | Passer `isOwner: true`, gérer callback |
| `_buildFallbackMap()` | Retirer "Réserver", changer texte |

---

**Validé pour développement** : En attente
**Date** : 2025-12-27
