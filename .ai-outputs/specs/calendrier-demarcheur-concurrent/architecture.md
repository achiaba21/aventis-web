# Architecture — Calendrier Démarcheur : Plages Concurrentes

## Vue d'ensemble

Périmètre : 3 fichiers modifiés, 2 fichiers créés. Aucune nouvelle dépendance. Aucun changement au BLoC ni au service.

## Logique DayAnalysis

```
DayAnalysis(plages: List<CalendarPlage>, userTelephone: String)

_normalize(tel) → supprime espaces → compare

Si plages vides ou toutes DISPONIBLE    → Cas A (vert,   clicable)
Si plages contient OCCUPE               → Cas B (rouge,  non clicable)
Si EN_ATTENTE dont _isMine() == true    → Cas D (amber,  non clicable)
Si EN_ATTENTE dont _isMine() == false   → Cas C (orange, clicable)

badgeCount = enAttentePlages.length (affiché si > 0)
```

## Structure des Fichiers

```
lib/
├── model/calendar/
│   └── calendar_plage.dart                              ← MODIFIER (+ demarcheurTelephone)
│
├── bloc/calendar_plage_bloc/
│   └── calendar_plage_state.dart                        ← MODIFIER (getPlagesForDay)
│
└── screen/client/demarcheur/calendrier/
    ├── demarcheur_calendar_screen.dart                  ← MODIFIER
    ├── helper/
    │   └── day_analysis.dart                            ← CRÉER
    └── widget/
        └── demarcheurs_en_attente_bottom_sheet.dart     ← CRÉER
```

## Couleurs

| Cas | Couleur |
|-----|---------|
| A (disponible) | Colors.green[700]!.withOpacity(0.25) |
| B (occupé) | Colors.red[700]! |
| C (concurrents) | Colors.orange |
| D (ma demande) | Colors.amber[700]! |

## CONTRAT D'IMPLÉMENTATION

### Modèles
- [ ] calendar_plage.dart → ajouter demarcheurTelephone: String? + fromJson

### State BLoC
- [ ] calendar_plage_state.dart → supprimer getStatusForDay, supprimer getPlageForDay → ajouter getPlagesForDay → List<CalendarPlage>

### Helpers (à créer)
- [ ] helper/day_analysis.dart → enum DayCas + class DayAnalysis (logique 4 cas)

### Widgets (à créer)
- [ ] widget/demarcheurs_en_attente_bottom_sheet.dart → bottom sheet avec liste + bouton conditionnel

### Écran existant
- [ ] demarcheur_calendar_screen.dart
    → DemarcheurCalendarScreen : récupérer userTelephone depuis UserBloc
    → _CalendarGrid : appeler getPlagesForDay(date), passer List<CalendarPlage> + userTelephone à _DayCell
    → _DayCell : remplacer PlageStatut? par List<CalendarPlage> + String userTelephone, instancier DayAnalysis
    → _DayCell.onTap : si Cas C/D → showModalBottomSheet, si Cas A → formulaire direct
    → _DayCell : afficher badge si DayAnalysis.hasBadge

UI_REQUIRED: true
