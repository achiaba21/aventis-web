# UI/UX Proposal : Amélioration de la Map

## Option Choisie : C - Carte Moderne

### Design System

**Palette de couleurs :**
| Élément | Couleur | Hex |
|---------|---------|-----|
| Marker normal | Gris foncé | `#2D2D2D` |
| Marker texte | Blanc | `#FFFFFF` |
| Marker sélectionné | Orange | `#FFA02A` |
| Zone overlay | Orange 20% | `#33FFA02A` |
| Géoloc actif | Bleu | `#4A90D9` |
| Géoloc inactif | Gris | `#666666` |

### 1. Custom Map Marker

**États :**

```
Normal (compact):
    ┌─────────┐
    │   25K   │  ← Fond #2D2D2D, texte blanc
    └────┬────┘
         ▼

Sélectionné (expanded + bounce):
   ┌───────────┐
   │  25K FCFA │  ← Fond orange, + grand
   │   ★ 4.5   │    avec note si disponible
   └─────┬─────┘
         ▼

Cluster (pulse animation):
     ╭───╮
     │ 5 │  ← Cercle avec nombre
     ╰───╯
```

**Spécifications :**
- Taille normale : 60x28 px
- Taille sélectionnée : 80x44 px
- Border radius : 14 px (pilule)
- Font : Bold, 13px (normal), 14px (sélectionné)
- Ombre : `0 2px 8px rgba(0,0,0,0.3)`

### 2. Bouton Géolocalisation (FAB)

**États :**
```
Inactif:     Recherche:     Centré:
  ┌───┐        ┌───┐         ┌───┐
  │ ◎ │        │ ◎ │ pulse   │ ◎ │
  └───┘        └───┘         └───┘
  gris         bleu animé    bleu fixe
```

**Spécifications :**
- Taille : 48x48 px
- Position : Bottom-right, 16px margin
- Icône : `Icons.my_location`
- Animation pulse : scale 1.0 → 1.2 → 1.0 (1s loop)

### 3. Zone Selector (Bottom Sheet)

**Layout :**
```
┌─────────────────────────────────────────┐
│  ▔▔▔▔▔▔▔▔▔▔▔  (handle 40x4px)           │
│                                         │
│  Rechercher dans une zone               │ ← Titre 16px bold
│                                         │
│  ┌─────────────┐  ┌─────────────┐       │
│  │  ○ Cercle   │  │ ○ Zone libre│       │ ← Radio buttons
│  └─────────────┘  └─────────────┘       │
│                                         │
│  Rayon                                  │
│  ──────────●────────────  2 km          │ ← Slider
│  0.5 km                      5 km       │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     Rechercher dans la zone     │    │ ← PlainButton
│  └─────────────────────────────────┘    │
│                                         │
│  Effacer la zone                        │ ← TextButton
└─────────────────────────────────────────┘
```

**Spécifications :**
- Height : 280px (collapsed), draggable
- Background : `Style.backgroundColor`
- Border radius top : 16px
- Padding : 16px

### 4. Zone Overlay sur Map

```
╭─────────────────────────────╮
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░                    ░░░ │
│ ░░░   Zone visible     ░░░ │  ← Fill: #FFA02A 20%
│ ░░░                    ░░░ │     Stroke: #FFA02A 2px
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░ │
╰─────────────────────────────╯
```

### 5. Layout Complet MapExploreScreen

```
┌─────────────────────────────────────────┐
│  ←    Carte des résidences    ≡    ↻   │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────┐         ┌─────┐                │
│  │ 25K │         │ 18K │    ╭───╮       │
│  └──┬──┘         └──┬──┘    │ 3 │       │
│     ▼               ▼       ╰───╯       │
│                                         │
│              ┌─────┐                    │
│              │ 32K │                    │
│              └──┬──┘                    │
│                 ▼                       │
│                                         │
│                                  ┌────┐ │
│                                  │ ◎  │ │ ← Géoloc FAB
│                                  └────┘ │
│                                  ┌────┐ │
│                                  │ ⬭  │ │ ← Zone FAB
│                                  └────┘ │
└─────────────────────────────────────────┘
```

### 6. Animations

| Élément | Animation | Durée |
|---------|-----------|-------|
| Marker tap | Bounce scale | 200ms |
| Marker select | Expand + elevate | 300ms |
| Cluster | Pulse scale | 1000ms loop |
| Géoloc search | Pulse opacity | 1000ms loop |
| Zone appear | Fade in | 200ms |
| Bottom sheet | Slide up | 300ms |

### 7. Tuiles Map

**Provider :** Stadia Maps (gratuit)
- Light : `https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png`
- Dark : `https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png`

Mode par défaut : Dark (cohérent avec le thème app)
