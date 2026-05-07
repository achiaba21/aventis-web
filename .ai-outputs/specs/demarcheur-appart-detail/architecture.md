# Architecture — Écran Détail Appartement Démarcheur

## 1. Vue d'ensemble

Remplacer le flux `_AppartementCard → DemarcheurCalendarScreen` par `_AppartementCard → DemarcheurAppartDetailScreen` (tout en un scrollable).

**Constat critique :** `AppartDetailContent` dépend de `ReservationBloc`. Inutilisable dans le contexte démarcheur. Le nouvel écran réutilise les sous-widgets indépendants uniquement.

## 2. Structure des Fichiers

```
lib/
├── widget/calendar/
│   └── appart_calendar_section.dart          ← NOUVEAU
├── screen/client/demarcheur/
│   ├── detail/
│   │   └── demarcheur_appart_detail_screen.dart  ← NOUVEAU
│   ├── home/
│   │   └── demarcheur_home.dart                  ← MODIFIÉ
│   └── calendrier/
│       └── demarcheur_calendar_screen.dart        ← SUPPRIMÉ
```

## 3. Contrats

### AppartCalendarSection
- StatefulWidget
- Props: `Appartement appartement`, `String userTelephone`
- Gère internalement: navigation form push, bottom sheet, refresh mois
- Widgets privés: `_MonthNavigator`, `_CalendarLegend`, `_LegendItem`, `_CalendarGrid`, `_DayCell`, `_BadgeDots`

### DemarcheurAppartDetailScreen
- StatelessWidget
- Props: `Appartement appartement`
- Scaffold + AppBar + SingleChildScrollView
- Contient `_DemarcheurAppartInfo` (widget privé)
- Aucune dépendance à ReservationBloc ni FavoriteBloc

## 4. Structure Visuelle

```
Scaffold (bg: containerColor3)
└── AppBar (dark, titre appartement)
└── SafeArea
    └── SingleChildScrollView
        └── Column
            ├── [si photos non vides] ImageCarousel(height: 300)
            ├── Padding → Column
            │   ├── AppartTitreInfo
            │   ├── [si description] DetailSectionCard("Description")
            │   └── [si rules] HouseRule
            ├── _SectionHeader("Disponibilités")
            └── AppartCalendarSection
```

## 5. CONTRAT D'IMPLÉMENTATION

### Fichiers à créer
- [ ] `lib/widget/calendar/appart_calendar_section.dart`
- [ ] `lib/screen/client/demarcheur/detail/demarcheur_appart_detail_screen.dart`

### Fichiers à modifier
- [ ] `lib/screen/client/demarcheur/home/demarcheur_home.dart`

### Fichiers à supprimer
- [ ] `lib/screen/client/demarcheur/calendrier/demarcheur_calendar_screen.dart`

### Widgets réutilisés sans modification
- `lib/widget/img/image_carousel.dart`
- `lib/widget/item/appart/appart_titre_info.dart`
- `lib/widget/detail_appart/detail_section_card.dart`
- `lib/screen/client/locataire/home/widget/house_rule.dart`
- `lib/screen/client/demarcheur/calendrier/widget/demarcheurs_en_attente_bottom_sheet.dart`
- `lib/screen/client/demarcheur/calendrier/helper/day_analysis.dart`
- `lib/screen/client/demarcheur/reservations/demarcheur_reservation_form_screen.dart`

UI_REQUIRED: true
