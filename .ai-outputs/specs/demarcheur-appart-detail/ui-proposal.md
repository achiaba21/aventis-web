# Design UI Validé

**Option choisie :** B — Style Locataire (immersif)

## Placement

Pas d'AppBar. Bouton retour flottant overlay par-dessus le carousel (comme AppartDetailScreen locataire).

## Structure Visuelle

```
Scaffold (bg: containerColor3, pas d'AppBar)
└── SafeArea
    └── Stack
        ├── SingleChildScrollView
        │   └── Column
        │       ├── Stack (photos zone)
        │       │   ├── ImageCarousel(height: 300) si photos
        │       │   │   OU Container(height: 180, color: surfaceColor) si pas de photos
        │       │   └── Bouton ← flottant (IconBoutton, bgColor: containerColor2)
        │       ├── Padding > Column
        │       │   ├── AppartTitreInfo
        │       │   ├── Gap
        │       │   ├── [si description] DetailSectionCard("Description")
        │       │   ├── Gap
        │       │   └── [si rules] HouseRule
        │       ├── _SectionHeader("Disponibilités")
        │       └── AppartCalendarSection
```

## Composants à Créer
- `DemarcheurAppartDetailScreen` (screen)
- `_DemarcheurAppartInfo` (widget privé inline)
- `_SectionHeader` (widget privé inline)
- `AppartCalendarSection` (widget réutilisable)

## Composants à Réutiliser
- `ImageCarousel` — photos carousel
- `IconBoutton` — bouton retour flottant
- `AppartTitreInfo` — titre + note + chambres/lits/douches
- `DetailSectionCard` — encart description
- `HouseRule` — règles maison

## Contraintes Visuelles
- Pas d'AppBar (bouton retour flottant overlay)
- Si pas de photos : Container(height: 180, color: surfaceColor) avec icône apartment centrée
- Bouton retour : IconBoutton existant, bgColor: Style.containerColor2
- Section "Disponibilités" : séparateur avec icône calendrier + texte, style cohérent
- Calendrier : fond containerColor3, continuité visuelle
