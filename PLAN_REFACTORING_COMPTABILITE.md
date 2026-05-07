# Plan de Refactoring - Système de Comptabilité

## Objectif
Simplifier le système de comptabilité en supprimant le modèle `RapportComptable` et en calculant toutes les métriques dynamiquement côté client à partir des réservations et charges.

## Principes
- **Pas de rapport pré-calculé** : tout est calculé à la volée
- **Source unique de vérité** : les données brutes (charges, réservations, résidences)
- **CRUD simple** : l'API ne fait que du CRUD sur les charges
- **Calculs purs** : un helper stateless pour tous les calculs

---

## Étapes d'implémentation

### Phase 1 : Création des nouveaux composants

#### 1.1 Créer `ComptabiliteCalculator`
- [x] Créer `lib/util/comptabilite_calculator.dart`
- [x] Implémenter les méthodes de calcul :
  - `chiffreAffaires(reservations, dateDebut, dateFin, residenceId?)`
  - `totalCharges(charges, dateDebut, dateFin)`
  - `beneficeNet(ca, charges)`
  - `margePourcent(ca, benefice)`
  - `tauxOccupation(reservations, appartements, dateDebut, dateFin)`
  - `joursReserves(reservations, dateDebut, dateFin)`
  - `chargesEnRetard(charges)`
  - `chargesEcheanceProche(charges, joursAvant)`
  - `repartitionParType(charges)`
  - `prixMoyenParNuit(ca, joursReserves)`
  - `historiqueMensuel(reservations, charges, nombreMois, residenceId?)`

#### 1.2 Créer `ChargeBloc` (nouveau bloc dédié)
- [x] Créer `lib/bloc/charge_bloc/charge_event.dart`
- [x] Créer `lib/bloc/charge_bloc/charge_state.dart`
- [x] Créer `lib/bloc/charge_bloc/charge_bloc.dart`
- [x] Events : LoadCharges, AddCharge, UpdateCharge, DeleteCharge, MarkAsPaid
- [x] State simple : ChargeInitial, ChargeLoading, ChargeLoaded, ChargeError

#### 1.3 Simplifier `ChargeRepository`
- [x] Créer `lib/repository/charge_repository.dart`
- [x] Garder uniquement : getCharges, createCharge, updateCharge, deleteCharge, markAsPaid
- [x] Supprimer : getRapport, getHistorique, getAlertes

#### 1.4 Simplifier `ChargeApiService`
- [x] Renommer `comptabilite_api_service.dart` → garder le nom mais simplifier
- [x] Supprimer : getRapport, getHistorique, getAlertes
- [x] Garder : CRUD charges uniquement

### Phase 2 : Créer le Cubit de filtres

#### 2.1 Créer `ComptabiliteFilterCubit`
- [x] Créer `lib/bloc/comptabilite_filter/comptabilite_filter_cubit.dart`
- [x] State : selectedResidenceId, selectedAppartementId, dateDebut, dateFin, viewMode
- [x] Méthodes : selectResidence, selectAppartement, selectPeriode, changeViewMode

### Phase 3 : Refactorer l'UI

#### 3.1 Modifier `ComptabiliteScreen`
- [x] Utiliser MultiBlocProvider/MultiBlocBuilder
- [x] Écouter : ResidenceBloc, ReservationBloc, ChargeBloc, ComptabiliteFilterCubit
- [x] Utiliser ComptabiliteCalculator pour tous les calculs
- [x] Supprimer la dépendance à RapportComptable

#### 3.2 Adapter les widgets
- [x] `DashboardCards` : recevoir les valeurs calculées en paramètres
- [x] `ChargeListSection` : recevoir List<Charge> directement
- [x] `EvolutionChart` : recevoir les données d'historique calculées
- [x] `ResidenceSelector` : utiliser ComptabiliteFilterCubit
- [x] `PeriodeSelector` : utiliser ComptabiliteFilterCubit
- [x] `AppartementSelector` : utiliser ComptabiliteFilterCubit

#### 3.3 Adapter `ChargeFormScreen`
- [x] Utiliser ChargeBloc au lieu de ComptabiliteBloc

### Phase 4 : Nettoyage

#### 4.1 Supprimer les fichiers obsolètes
- [x] Supprimer `lib/model/comptabilite/rapport_comptable.dart`
- [x] Supprimer `lib/bloc/comptabilite_bloc/` (tout le dossier)
- [x] Supprimer `lib/repository/comptabilite_repository.dart`
- [x] Supprimer les endpoints inutiles dans l'API service

#### 4.2 Mettre à jour les imports
- [x] Rechercher et remplacer tous les imports de ComptabiliteBloc
- [x] Rechercher et remplacer tous les imports de RapportComptable

### Phase 5 : Tests et validation

- [ ] Tester le CRUD des charges
- [ ] Tester les calculs du ComptabiliteCalculator
- [ ] Tester l'affichage des métriques
- [ ] Tester les filtres (résidence, période, appartement)
- [ ] Tester le mode offline (cache local)

---

## Structure finale des fichiers

```
lib/
├── model/
│   └── comptabilite/
│       ├── charge.dart              ✓ GARDER
│       ├── type_charge.dart         ✓ GARDER
│       ├── frequence_charge.dart    ✓ GARDER
│       └── appartement_info.dart    ✓ GARDER
│
├── service/
│   └── comptabilite/
│       ├── comptabilite_api_service.dart  ✓ SIMPLIFIÉ (CRUD uniquement)
│       └── charge_local_service.dart      ✓ GARDER
│
├── repository/
│   └── charge_repository.dart       ✓ CRÉÉ (simplifié)
│
├── bloc/
│   ├── charge_bloc/                 ✓ CRÉÉ
│   │   ├── charge_bloc.dart
│   │   ├── charge_event.dart
│   │   └── charge_state.dart
│   │
│   └── comptabilite_filter/         ✓ CRÉÉ
│       └── comptabilite_filter_cubit.dart
│
├── util/
│   └── comptabilite_calculator.dart ✓ CRÉÉ
│
└── screen/client/proprio/comptabilite/
    ├── comptabilite_screen.dart     ✓ REFACTORÉ
    ├── charge_form_screen.dart      ✓ ADAPTÉ
    ├── export/
    │   └── pdf_export_service.dart  ✓ ADAPTÉ
    └── widget/
        ├── dashboard_cards.dart     ✓ ADAPTÉ
        ├── charge_list_section.dart ✓ ADAPTÉ
        ├── evolution_chart.dart     ✓ ADAPTÉ
        └── ...
```

## Fichiers supprimés
- [x] `lib/model/comptabilite/rapport_comptable.dart`
- [x] `lib/bloc/comptabilite_bloc/comptabilite_bloc.dart`
- [x] `lib/bloc/comptabilite_bloc/comptabilite_event.dart`
- [x] `lib/bloc/comptabilite_bloc/comptabilite_state.dart`
- [x] `lib/repository/comptabilite_repository.dart`

---

## Notes importantes

1. **Migration progressive** : On crée les nouveaux composants avant de supprimer les anciens ✓
2. **Pas de breaking changes API** : Le backend garde les mêmes endpoints CRUD ✓
3. **Offline first** : Le ChargeLocalService reste pour le cache ✓
4. **Réutilisation** : Les autres BLoCs (Residence, Reservation) ne changent pas ✓

---

## Résumé des changements

### Avant (architecture rigide)
- `RapportComptable` : modèle avec valeurs pré-calculées par le serveur
- `ComptabiliteBloc` : dépendant de l'API `/rapport`
- Double source de vérité (serveur vs local)
- Injection manuelle des données (setReservations, setResidences)

### Après (architecture flexible)
- **Pas de RapportComptable** : tout est calculé dynamiquement
- `ChargeBloc` : CRUD simple uniquement
- `ComptabiliteCalculator` : fonctions pures pour tous les calculs
- `ComptabiliteFilterCubit` : gestion des filtres UI
- `MultiBlocBuilder` : accès direct aux données (réservations, résidences, charges)
- Source unique de vérité : les données brutes
