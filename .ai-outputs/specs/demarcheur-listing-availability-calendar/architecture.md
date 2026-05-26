# Architecture — `demarcheur-listing-availability-calendar`

**Date :** 2026-05-24

## Fichiers

### CRÉER
- `lib/screen/client/demarcheur/listings/widget/listing_availability_calendar.dart`
  - Widget lecture seule : MiniCalendarGrid + légende (Libre/Réservé) + hint
  - Props : `CalendarResponse? data`, `bool isLoading`, `DateTime month`, `onPrev`, `onNext`

### MODIFIER
- `lib/screen/client/demarcheur/listings/widget/partner_listing_card.dart`
  - + `isSelected: bool`
  - + `calendarWidget: Widget?`
  - trailing : chevron_right → radio indicator (cercle / coche)
  - si isSelected : rend calendarWidget en bas (même conteneur)

- `lib/screen/client/demarcheur/listings/demarcheur_listings_screen.dart`
  - State : `_selectedId`, `_calendarMonth`, `_calendarCache`, `_loadingIds`
  - onTap → sélectionne + charge calendrier via CalendarService
  - "Continuer" button sticky en bas
  - Titre : "Choisir un logement"

## Flux de données
tap(appart) → _selectedId = appart.id → CalendarService.getDemarcheurCalendar → cache → ListingAvailabilityCalendar
prev/next → setState(_calendarMonth), borne min = 1er du mois courant
Continuer → pushScreen(DemarcheurAppartDetailScreen)

## Décisions
- Pas de nouveau BLoC — état UI éphémère dans le State
- CalendarService appelé directement (pattern existant)
- MiniCalendarGrid réutilisé tel quel

UI_REQUIRED: true
