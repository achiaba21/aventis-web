# 📄 TODO — Branchement calendrier côté Locataire

> **Date :** 2026-05-13
> **Contexte :** suite du chantier calendrier (proprio + démarcheur livrés).
> **Statut :** non démarré — à faire **après** le reste du périmètre proprio en cours.

---

## 🎯 Objectif

Étendre la logique anti-intersection déjà livrée pour proprio + démarcheur au
tunnel de réservation locataire, afin que :
- Le locataire ne puisse **jamais** sélectionner une plage déjà occupée
- Il voie clairement la dispo avant de cliquer « Réserver »
- Le backend n'expose **pas** les infos privées (`reference`, `montant`,
  `demarcheurNom`, `demarcheurTelephone`, `montantCommission`) au locataire

---

## ✅ Briques déjà disponibles (à réutiliser tel quel)

| Brique | Path | Statut |
|---|---|---|
| Helper pur `CalendarAvailability` | `lib/util/calc/calendar_availability.dart` | ✅ 12 tests verts |
| `CalendarPlageBloc` + events | `lib/bloc/calendar_plage_bloc/` | ✅ |
| Modèle `CalendarPlage` + `containsDay` | `lib/model/calendar/calendar_plage.dart` | ✅ |
| Widget `MiniCalendarGrid` + `CalendarLegend` | `lib/screen/client/proprio/appartements/widget/` | ✅ |
| Pattern picker avec `selectableDayPredicate` | `new_referral_screen.dart` (référence) | ✅ |

---

## 🚨 Trous Flutter

### 1. `LocataireReserveScreen.step1` — picker dates no-op

**Fichier :** `lib/screen/client/locataire/booking/reserve_screen.dart:115-119`

Actuel :
```dart
FieldRow(
  eyebrow: 'DATES',
  value: '12 - 15 nov. 2025',  // ← hardcodé
  onTap: () {},                 // ← NO-OP
)
```

**À faire :**
- Remplacer par un `showDateRangePicker` (ou 2 `showDatePicker`) avec
  `selectableDayPredicate` consommant `CalendarAvailability.isDayAvailable`
- Conserver le pattern visuel `FieldRow` mais rendre le tap fonctionnel
- Mettre à jour `widget.nights` dynamiquement → recalculer `_subtotal`,
  `_fees`, `_total`
- Bloquer le bouton "Continuer vers le paiement" si la plage finale échoue
  `CalendarAvailability.isRangeAvailable`
- Idem pour le `FieldRow` "VOYAGEURS" (no-op aujourd'hui)

### 2. `LocataireDetailScreen` — pas d'indicateur de dispo

**Fichier :** `lib/screen/client/locataire/booking/detail_screen.dart`

**À faire (optionnel V1) :**
- Ajouter une section compacte « Disponibilités » entre `DetailMapSection`
  et le bloc « Avis » :
  - Mini-calendrier read-only (réutilise `MiniCalendarGrid`, `onDayTap: null`)
  - OU texte simple « Disponible dès le {prochaineDate} » si on calcule
    côté Flutter la prochaine plage libre

### 3. `CalendarService.getLocataireCalendar()` manquant

**Fichier :** `lib/service/model/calendar/calendar_service.dart`

**À faire :**
```dart
Future<CalendarResponse> getLocataireCalendar(
  int appartId, {
  DateTime? debut,
  DateTime? fin,
}) async {
  // GET api/locataire/appartements/{id}/calendar
  // (à créer côté backend, cf. section sécurité)
}
```

### 4. `CalendarPlageBloc` — extension du flag rôle

**Fichier :** `lib/bloc/calendar_plage_bloc/calendar_plage_event.dart`

Actuel : `LoadCalendarPlages` a un `bool isDemarcheur` (binaire proprio/démarcheur).

**À faire :** passer à un `enum CalendarCallerRole { locataire, proprio, demarcheur }`
+ adapter `_onLoadCalendarPlages` pour appeler `getLocataireCalendar` quand
le rôle est locataire. Aliases deprecated possibles pour rétro-compat.

---

## 🚨 Trous backend — Sécurité DTO

### Problème

Le `CalendarPlageDTO` actuel expose **tout** :
```java
private String reference;           // ← privé !
private String demarcheurNom;       // ← privé !
private String demarcheurTelephone; // ← très privé !
private double montant;             // ← privé !
private Double montantCommission;   // ← très privé !
```

**OK** pour proprio (sa propre annonce) et démarcheur (ses propres clients),
**PAS OK** pour locataire qui ne doit voir que `debut/fin/statut`.

### Option A (recommandée) — Endpoint locataire dédié

```
GET /api/locataire/appartements/{id}/calendar?debut=...&fin=...
```

Réponse : `LocataireCalendarPlageDTO` réduit
```json
{
  "appartId": 12,
  "plages": [
    { "debut": "2026-06-10T12:00", "fin": "2026-06-15T11:00", "statut": "OCCUPE" }
  ]
}
```

Champs exposés : **uniquement** `debut`, `fin`, `statut`. Pas de `type`
(masque l'origine démarcheur vs locataire), pas de `reference`, pas de
montants, pas d'infos démarcheur.

### Option B — Filtrage in-place côté serveur

Le DTO existant est retourné mais les champs sensibles sont `null` selon
le rôle de l'appelant (SecurityContext). Moins propre car le contrat du
DTO devient ambigu.

→ **Recommandation : Option A**, contrat explicite, audit facile.

---

## 📋 Plan d'implémentation (par ordre)

| # | Effort | Action | Côté |
|---|---|---|---|
| 1 | 30 min | Créer `LocataireCalendarPlageDTO` + endpoint `/api/locataire/appartements/{id}/calendar` | Backend |
| 2 | 10 min | Ajouter `CalendarService.getLocataireCalendar()` | Flutter |
| 3 | 15 min | Étendre `LoadCalendarPlages` avec `CalendarCallerRole` enum (ou alias deprecated du `isDemarcheur`) | Flutter |
| 4 | 30 min | Brancher `LocataireReserveScreen.step1` : `showDateRangePicker` + `selectableDayPredicate` + recalcul `nights` | Flutter |
| 5 | 10 min | Bloquer "Continuer vers le paiement" si `!isRangeAvailable` + banner danger | Flutter |
| 6 | 20 min | (Optionnel) Section « Disponibilités » sur `LocataireDetailScreen` | Flutter |
| 7 | 10 min | `flutter analyze` + retest unitaires (helpers déjà couverts) | Flutter |

**Effort total estimé** : 1h30 — 2h.

---

## 🩺 Cohérence à vérifier

- `CalendarPlage.containsDay` exclut la borne `fin` (jour check-out
  libérable). `MiniCalendarGrid._daysOfMonthFor` (dans `listing_calendar_tab`)
  l'inclut. **Incohérence préexistante** — à uniformiser avant de
  brancher le locataire pour éviter les divergences UX.

- Sur `NewReferralScreen`, la fenêtre chargée est **12 mois glissants**.
  Pour le locataire, on peut probablement charger une fenêtre plus courte
  (3-6 mois) car les locataires réservent souvent court terme. À cadrer.

---

## 🔗 Liens

- Spécification calendrier proprio livrée : `lib/screen/client/proprio/appartements/widget/listing_calendar_tab.dart`
- Spécification calendrier démarcheur livrée : `lib/screen/client/demarcheur/referrals/new_referral_screen.dart`
- Helper réutilisable : `lib/util/calc/calendar_availability.dart`
- Tests référence : `test/util/calc/calendar_availability_test.dart`
