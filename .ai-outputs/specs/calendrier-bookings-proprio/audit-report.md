# 🔍 Rapport d'Audit — `calendrier-bookings-proprio`

> **Date :** 2026-05-16
> **Auditeur :** Agent Audit
> **Spec source :** `business-spec.md` + `architecture.md`
> **Tentative :** 1/3

---

## 📊 Scores

| Dimension       | Score      | Problèmes   | Statut |
| --------------- | ---------- | ----------- | ------ |
| Complexité      | 90/100     | 🚨0 ⚠️1 ℹ️0 | ✅     |
| Lisibilité      | 100/100    | 🚨0 ⚠️0 ℹ️0 | ✅     |
| DRY             | 95/100     | 🚨0 ⚠️0 ℹ️1 | ✅     |
| Documentation   | 100/100    | 🚨0 ⚠️0 ℹ️0 | ✅     |
| SOLID           | 95/100     | 🚨0 ⚠️0 ℹ️1 | ✅     |
| Dette technique | 100/100    | 🚨0 ⚠️0 ℹ️0 | ✅     |
| **GLOBAL**      | **97/100** |             | **✅ VALIDÉ** |

Aucun problème critique. 1 problème majeur (longueur fichier). 2 améliorations mineures.

---

## ✅ Indicateurs automatiques (grep)

| Indicateur | Résultat | Constat |
|---|---|---|
| `Widget _buildXxx()` privé | **0** | Règle 1 respectée |
| `TODO` / `FIXME` / `HACK` | **0** | Pas de dette cachée |
| `print()` debug | **0** | Production-ready |
| `catch {}` vide | **0** | Gestion d'erreurs propre |
| `alignment: Alignment.X` sur Container | **0** | Memory `feedback_container_alignment_bug.md` respectée |
| Erreurs `flutter analyze` | **0** | Code compile sans warning critique |
| Tests verts | **171 / 171** | Couverture +51 tests nouveaux, 0 régression |

---

## 📐 Conformité au Contrat (architecture.md §7)

| Section | Items | Statut |
|---|---|---|
| 7.1 Enums + Modèles (3 items) | `ReservationManuelleSource`, audit `MoyenPaiement` (étendu), `ReservationManuelleReq` (étendu) | ✅ |
| 7.2 Utils purs (4 items) | `TipSuggestionEngine`, `ActiveBookingsCounter`, `ManqueAGagnerCalculator`, `ManualReservationValidator` | ✅ |
| 7.3 BLoC wizard (3 fichiers) | Event + State + Bloc avec dispatch sur `ReservationBloc` | ✅ |
| 7.4 Écran principal | `CalendarBookingsScreen` orchestrateur multi-annonces | ✅ |
| 7.5 Atoms écran (7 items) | `AppartementChipsRow`, `SelectedAppartHeader`, `CalendarStatsRow`, `CalendarStatCell`, `CalendarTipBanner`, `MonthBookingsList`, `BookingRow` | ✅ |
| 7.6 ActionSheet + BlockDialog | 2 modaux complets | ✅ |
| 7.7 Wizard (screen + 3 steps + 5 atoms) | `ManualReservationWizardScreen` + `StepDates`/`StepClientInfo`/`StepConfirmation` + `SourcePicker`/`PaymentMethodChips`/`ReservationRecapCard`/`DemarcheurPickerSheet` + `RangeCalendarPicker`/`RangeCalendarDayCell` | ✅ |
| 7.8 Dashboard intégration | `CalendarBookingsCard` + insertion dans `dashboard_screen.dart` entre KpiGrid et CashflowSection | ✅ |
| 7.9 Tests (5 fichiers) | 51 tests nouveaux | ✅ |
| 7.10 Doc backend | `BACKEND_NOTES_RESERVATION_DETAIL.md` §0 ajouté | ✅ |
| 7.11 Conventions | 10 règles + SOLID + mémoire | ✅ |

**100% du contrat respecté.**

---

## 📐 Conformité aux Critères d'Acceptation (business-spec §8)

| # | Critère | Vérification | Statut |
|---|---|---|---|
| 1 | Card dashboard avec bon comptage « N séjours en cours » | `ActiveBookingsCounter.activeToday(reservations)` calculé en builder dashboard | ✅ |
| 2 | Écran calendrier affiche 1re annonce par défaut + chips scrollables | `_initSelection()` prend `apparts.first` si pas d'`initialAppartementId` | ✅ |
| 3 | Stats du mois correctes (inclut blocages proprio) | `ManqueAGagnerCalculator` testé : (libres + bloqués) × prix | ✅ |
| 4 | Bandeau Conseil si `joursLibres ≥ 4` dans la semaine | `TipSuggestionEngine.seuilJoursLibres = 4`, retourne null sinon | ✅ |
| 5 | Liste « Réservations du mois » filtre correctement | `_reservationsDuMois` filtre par appartId + statut != annulé + overlap mois | ✅ |
| 6 | Bouton ActionSheet 2 options | `ManualReservationActionSheet` (block / reserve) | ✅ |
| 7 | « Bloquer une période » dispatch `AvailabilityBloc` sans wizard | `BlockPeriodDialog` → `BlockDates(appartId, range)` direct | ✅ |
| 8 | « Réserver client direct » ouvre wizard 3 étapes | `_openWizard()` → `pushScreen(ManualReservationWizardScreen)` | ✅ |
| 9 | Wizard step 1 empêche sélection plage en conflit | `RangeCalendarDayCell.isUnavailable` + `ManualReservationValidator.validateDates` | ✅ |
| 10 | Wizard step 2 a 2 sources (pas « Via Asfar ») | `ReservationManuelleSource.values.length == 2` (clientDirect, demarcheurPartenaire) | ✅ |
| 11 | Wizard step 2 demande mode paiement parmi 4 chips | `MoyenPaiement.manualReservationOptions.length == 4` (Espèces, Wave, OM, Virement) | ✅ |
| 12 | Wizard step 3 affiche référence + retour calendrier | `StepConfirmation` rend `reference` + CTA `back(context)` | ✅ |
| 13 | Date d'arrivée passée autorisée | Validator n'a aucun check `isAfter(now)` — dates passées passent | ✅ |
| 14 | Calendrier mis à jour automatiquement après création | `_openWizard().then(_loadDataFor)` au retour | ✅ |

**14 / 14 critères atteints.**

---

## ⚠️ Problèmes Majeurs

### Complexité — Longueur du fichier `calendar_bookings_screen.dart`

**Fichier :** `lib/screen/client/proprio/calendrier/calendar_bookings_screen.dart`
**Constat :** 435 lignes, contient 3 classes (`_CalendarBookingsScreenState`, `_ChipsHeaderDelegate`, `_CalendarContent`).
**Mesure :** 435 LOC > seuil 300 (⚠️). Sous le seuil critique 500.
**Pénalité :** -10 (1 ⚠️ majeur)

**Correction suggérée (non bloquante)** :

Extraire `_CalendarContent` (lignes 263-435, ~170 LOC) dans un fichier dédié :
- `lib/screen/client/proprio/calendrier/widget/calendar_content_view.dart`
- Renommer en `CalendarContentView` (public)
- Le screen principal passe sous 270 LOC

Idem possible pour `_ChipsHeaderDelegate` (40 LOC).

**Pourquoi non bloquant** : les classes privées internes sont liées au context spécifique du screen et bien encapsulées. L'extraction améliorerait la lisibilité mais n'apporte pas de valeur fonctionnelle.

---

## ℹ️ Améliorations Suggérées (non bloquantes)

### 1. DRY — duplication mineure entre `_validateCurrentStep` et `_validateAllSteps`

**Fichier :** `lib/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_bloc.dart:174-214`

Les 4 validateurs (`validateDates`, `validateClient`, `validateSource`, `validatePaiement`) sont appelés dans des ordres légèrement différents entre :
- `_validateCurrentStep(s)` case 2 → client + source + paiement (sans dates)
- `_validateAllSteps(s)` → dates + client + source + paiement (tout)

**Correction suggérée** : extraire une méthode `_collectStepErrors(s, {includeDates = false})` qui factorise les 3 validateurs communs.

**Pourquoi acceptable** : la duplication est minime (3 lignes) et explicite. La factorisation introduirait un paramètre de configuration.

---

### 2. SOLID — Logique de calcul dans `_CalendarContent` (SRP)

**Fichier :** `lib/screen/client/proprio/calendrier/calendar_bookings_screen.dart:282-330`

3 méthodes calculent des données dérivées dans le widget :
- `_daysWith(plages, statut)` — liste des jours par statut
- `_joursDistincts(plages, statuts)` — comptage distinct
- `_reservationsDuMois(all)` — filtrage par mois et statut

**Correction suggérée** : extraire dans un util pur dédié (e.g. `lib/util/calc/calendar_plage_grouper.dart`) avec tests dédiés. Améliorerait :
- Testabilité (peut être testé indépendamment)
- Réutilisation (autres écrans pourraient en profiter)
- SRP (le widget ne fait que orchestrer)

**Pourquoi acceptable** : la logique est triviale et fortement liée au mois affiché par le widget. L'extraction apporte une amélioration mais n'est pas critique.

---

## 🎯 Détail par dimension

### 1. Complexité — 90/100

- ✅ Fonction max : ~35 lignes (`_onPublish` du wizard bloc avec doc)
- ✅ Paramètres max : 8 sur `StepClientInfo` (justifié par le formulaire)
- ✅ Imbrication max : 3 niveaux
- ⚠️ Fichier max : 435 LOC (`calendar_bookings_screen.dart`) — voir Problèmes Majeurs

### 2. Lisibilité — 100/100

- ✅ Aucun nom cryptique : `nbNuits`, `totalClient`, `joursLibres`, `joursOccupes`, `manqueAGagner` tous explicites
- ✅ Magic numbers extraits : `seuilJoursLibres = 4`, `joursMaxSuggeres = 4`, `tauxOccupationMoyenFallback = 0.70`, `cinqPlusMinChambres = 4`
- ✅ Verbes pour les méthodes : `compute`, `validate`, `resolve`, `format`, `isCoherent`
- ✅ camelCase cohérent (sauf `MoyenPaiement.OM/WAVE/...` UPPER_CASE préexistant, rétro-compat préservée)

### 3. DRY — 95/100

- ✅ Atoms réutilisés (cf. liste dans le brief) : pas de duplication visuelle
- ✅ Utils statiques purs centralisent la logique métier
- ✅ Enum strict avec value/label/description évite les switches éparpillés
- ℹ️ Mineure duplication validators wizard (cf. amélioration 1)

### 4. Documentation — 100/100

- ✅ Toutes les classes ont une dartdoc avec rôle + référence spec
- ✅ Toutes les méthodes publiques documentées
- ✅ Commentaires WHY explicites :
  - « Changement de source : si on quitte demarcheurPartenaire, on clear le demarcheurId pour éviter une incohérence »
  - « Note: "dure" sans 'e' selon spec serveur historique »
  - « Sélection après start → set end (exclusif : checkout = jour libérable) »
- ✅ Références spec inlinées : `§4.1`, `§4.2`, `§4.4`, `§4.5`, `§4.6`, `§4.7`

### 5. SOLID — 95/100

- ✅ **SRP** : 1 fichier = 1 responsabilité. Utils purs / BLoC pilotage / Screen orchestration / Atoms présentation
- ✅ **OCP** : Enums extensibles via `values`, `manualReservationOptions` liste filtrée
- ✅ **LSP** : Pas de hiérarchie polymorphe ajoutée
- ✅ **ISP** : BLoC expose les events strictement nécessaires (5 events utilisateur + 2 notifications internes)
- ✅ **DIP** : `ManualReservationWizardBloc` reçoit `ReservationBloc` en injection
- ℹ️ `_CalendarContent` mélange légèrement logique de calcul et présentation (cf. amélioration 2)

### 6. Dette technique — 100/100

- ✅ 0 TODO/FIXME/HACK/XXX dans le nouveau code
- ✅ 0 print debug
- ✅ 0 catch vide
- ✅ 0 code commenté
- ✅ Aucun God Object (max 435 LOC)
- ✅ Aucune Long Method (max ~35 LOC)
- ✅ Compat backend documentée explicitement (`BACKEND_NOTES_RESERVATION_DETAIL.md §0`)
- ✅ V2 reportée (DemarcheurPicker) documentée en clair, pas une dette cachée

---

## 🧪 Qualité des tests

| Test file | Tests | Couverture qualitative |
|-----------|-------|-----------------------|
| `active_bookings_counter_test.dart` | 10 | Cas dates null, statuts variés, fin exclue, debut inclus, multi-réservations, now injecté |
| `manque_a_gagner_calculator_test.dart` | 7 | Mois plein/vide, blocages vs occupé, plage débordante, prix nul/négatif |
| `tip_suggestion_engine_test.dart` | 10 | Seuils, taux historique custom, plafonnement à 4 jours, blocages comme libres, milieu de nuit |
| `manual_reservation_validator_test.dart` | 14 | 4 méthodes × cas limites (null, vide, conflit, source démarcheur sans id, dates passées rétroactives) |
| `manual_reservation_wizard_bloc_test.dart` | 10 | Init, UpdateField, NextStep validation, totaux avec commission, PrevStep, ReservationCreatedSuccess |

**Pas de mocks** sur les utils métier — tests purs comme demandé.

`flutter test` complet : **171 / 171 verts** (51 nouveaux + 120 existants intacts — y compris les tests précédents `appartement_type_location`, `validator`, `bloc wizard appart`, `charge mapper`, etc., aucune régression).

---

## 🏁 Verdict Final

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ VALIDÉ                                                   ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Score Final : 97/100                                        ║
║                                                               ║
║  Problèmes critiques : 0                                     ║
║  Problèmes majeurs   : 1 (longueur fichier, non bloquant)    ║
║  Améliorations mineures : 2                                  ║
║                                                               ║
║  Conformité contrat archi      : 100% (11 sections)          ║
║  Conformité critères acceptation : 14/14                     ║
║  Conformité 10 règles Flutter  : 10/10                       ║
║  Tests verts                   : 171/171 (51 nouveaux)       ║
║                                                               ║
║  → Continuer vers Documentation                              ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

**Tentative :** 1/3 — Pas de boucle de correction nécessaire.

**Action suivante :** orchestrateur appelle `/agent-doc` pour la documentation HTML.
