# Plan d'implémentation - Cache Hive pour Propriétaires

## Objectif

Implémenter un système de cache Hive pour les données propriétaires (résidences, appartements, charges) afin d'éviter les rechargements abusifs et permettre un démarrage instantané de l'application.

---

## Convention de nommage

| Couche | Pattern | Responsabilité |
|--------|---------|----------------|
| `model_repository.dart` | Singleton | Stockage local Hive |
| `model_service.dart` | Singleton | Appels API serveur |
| `model_bloc.dart` | BLoC | Logique métier et gestion d'état |

---

## Architecture cible

```
┌─────────────────────────────────────────────────────────────┐
│                           UI                                 │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      MODEL_BLOC                              │
│  - Gère l'état (Loading, Loaded, Error)                     │
│  - Orchestre Repository (Hive) et Service (API)             │
│  - Pattern Cache-First                                       │
└─────────────────────────────┬───────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│   MODEL_REPOSITORY      │     │     MODEL_SERVICE       │
│   (Hive - Local)        │     │     (API - Serveur)     │
├─────────────────────────┤     ├─────────────────────────┤
│ - TypeAdapter           │     │ - Dio HTTP Client       │
│ - Box<Model>            │     │ - Endpoints REST        │
│ - CRUD local            │◀────│ - Sync après succès     │
│ - Métadonnées cache     │     │                         │
└─────────────────────────┘     └─────────────────────────┘
```

---

## Fichiers à créer

### 1. TypeAdapters Hive

| Fichier | Type ID | Description |
|---------|---------|-------------|
| `lib/model/residence/residence.g.dart` | 3 | Adapter généré pour Residence |
| `lib/model/residence/appart.g.dart` | 4 | Adapter généré pour Appartement |
| `lib/model/residence/address.g.dart` | 5 | Adapter généré pour Address |
| `lib/model/comptabilite/charge.g.dart` | 6 | Adapter généré pour Charge |

### 2. Repositories Hive

| Fichier | Box Name | Description |
|---------|----------|-------------|
| `lib/repository/residence_repository.dart` | `residences` | CRUD local résidences |
| `lib/repository/appartement_repository.dart` | `appartements` | CRUD local appartements |
| `lib/repository/charge_repository.dart` | `charges` | CRUD local charges (fusionné) |

---

## Fichiers à modifier

| Fichier | Modifications |
|---------|---------------|
| `lib/model/residence/residence.dart` | Ajouter annotations `@HiveType`, `@HiveField` |
| `lib/model/residence/appart.dart` | Ajouter annotations `@HiveType`, `@HiveField` |
| `lib/model/residence/address.dart` | Ajouter annotations `@HiveType`, `@HiveField` |
| `lib/model/comptabilite/charge.dart` | Ajouter annotations `@HiveType`, `@HiveField` |
| `lib/service/storage/storage_service.dart` | Enregistrer adapters, ajouter boxes |
| `lib/bloc/residence_bloc/residence_bloc.dart` | Intégrer pattern cache-first |
| `lib/bloc/appartement_bloc/appartement_bloc.dart` | Intégrer pattern cache-first |
| `lib/bloc/charge_bloc/charge_bloc.dart` | Intégrer pattern cache-first |
| `lib/service/preload/executors/residence_preload_executor.dart` | Charger depuis cache |

---

## Fichiers à supprimer

| Fichier | Raison |
|---------|--------|
| `lib/service/comptabilite/charge_local_service.dart` | Fusionné dans `ChargeRepository` |
| `lib/repository/proprio_repository.dart` | Remplacé par repositories séparés |

---

## Étapes d'implémentation

### Phase 1 : Préparation des modèles avec TypeAdapters

#### 1.1 Ajouter les dépendances (pubspec.yaml)

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

#### 1.2 Annoter les modèles

**Residence** (`lib/model/residence/residence.dart`):
```dart
import 'package:hive/hive.dart';

part 'residence.g.dart';

@HiveType(typeId: 3)
class Residence extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? nom;

  @HiveField(2)
  Address? address;

  @HiveField(3)
  String? reference;

  @HiveField(4)
  List<Appartement>? appartements;

  // ... reste du code
}
```

**Appartement** (`lib/model/residence/appart.dart`):
```dart
import 'package:hive/hive.dart';

part 'appart.g.dart';

@HiveType(typeId: 4)
class Appartement extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? residenceId;

  @HiveField(2)
  String? titre;

  @HiveField(3)
  double? prix;

  // ... autres champs avec @HiveField(n)
}
```

#### 1.3 Générer les adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Phase 2 : Mise à jour de StorageService

**Fichier**: `lib/service/storage/storage_service.dart`

```dart
class StorageService {
  // Boxes existantes
  late Box _authBox;
  late Box _userBox;

  // Nouvelles boxes
  late Box<Residence> _residencesBox;
  late Box<Appartement> _appartementsBox;
  late Box<Charge> _chargesBox;

  // Clés pour métadonnées
  static const String _residencesLastSyncKey = 'residences_last_sync';
  static const String _appartementsLastSyncKey = 'appartements_last_sync';
  static const String _chargesLastSyncKey = 'charges_last_sync';

  Future<void> init() async {
    // Enregistrer les adapters (ordre important: dépendances d'abord)
    Hive.registerAdapter(AddressAdapter());      // typeId: 5
    Hive.registerAdapter(ResidenceAdapter());    // typeId: 3
    Hive.registerAdapter(AppartementAdapter());  // typeId: 4
    Hive.registerAdapter(ChargeAdapter());       // typeId: 6

    // Ouvrir les boxes
    _authBox = await Hive.openBox('auth');
    _userBox = await Hive.openBox('user');
    _residencesBox = await Hive.openBox<Residence>('residences');
    _appartementsBox = await Hive.openBox<Appartement>('appartements');
    _chargesBox = await Hive.openBox<Charge>('charges');
  }

  // Getters pour les boxes
  Box<Residence> get residencesBox => _residencesBox;
  Box<Appartement> get appartementsBox => _appartementsBox;
  Box<Charge> get chargesBox => _chargesBox;

  // Métadonnées de synchronisation
  DateTime? getLastSync(String key) {
    final timestamp = _authBox.get(key);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> setLastSync(String key) async {
    await _authBox.put(key, DateTime.now().toIso8601String());
  }
}
```

---

### Phase 3 : Créer les Repositories

#### 3.1 ResidenceRepository

**Fichier**: `lib/repository/residence_repository.dart`

```dart
import 'package:hive/hive.dart';
import 'package:asfar/model/residence/residence.dart';
import 'package:asfar/service/storage/storage_service.dart';

class ResidenceRepository {
  // Singleton
  static final ResidenceRepository _instance = ResidenceRepository._internal();
  factory ResidenceRepository() => _instance;
  ResidenceRepository._internal();

  Box<Residence> get _box => StorageService.instance.residencesBox;

  // ==================== READ ====================

  /// Récupère toutes les résidences depuis le cache
  List<Residence> getAll() {
    return _box.values.toList();
  }

  /// Récupère une résidence par ID
  Residence? getById(int id) {
    try {
      return _box.values.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si le cache contient des données
  bool get hasData => _box.isNotEmpty;

  /// Récupère le timestamp de dernière synchronisation
  DateTime? get lastSync => StorageService.instance.getLastSync('residences_last_sync');

  // ==================== WRITE ====================

  /// Sauvegarde une liste de résidences (remplace tout)
  Future<void> saveAll(List<Residence> residences) async {
    await _box.clear();
    for (final residence in residences) {
      if (residence.id != null) {
        await _box.put(residence.id, residence);
      }
    }
    await StorageService.instance.setLastSync('residences_last_sync');
  }

  /// Sauvegarde ou met à jour une résidence
  Future<void> save(Residence residence) async {
    if (residence.id != null) {
      await _box.put(residence.id, residence);
    }
  }

  /// Supprime une résidence
  Future<void> delete(int id) async {
    await _box.delete(id);
  }

  /// Vide le cache
  Future<void> clear() async {
    await _box.clear();
  }
}
```

#### 3.2 AppartementRepository

**Fichier**: `lib/repository/appartement_repository.dart`

```dart
import 'package:hive/hive.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/storage/storage_service.dart';

class AppartementRepository {
  // Singleton
  static final AppartementRepository _instance = AppartementRepository._internal();
  factory AppartementRepository() => _instance;
  AppartementRepository._internal();

  Box<Appartement> get _box => StorageService.instance.appartementsBox;

  // ==================== READ ====================

  List<Appartement> getAll() {
    return _box.values.toList();
  }

  Appartement? getById(int id) {
    try {
      return _box.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Appartement> getByResidenceId(int residenceId) {
    return _box.values.where((a) => a.residenceId == residenceId).toList();
  }

  bool get hasData => _box.isNotEmpty;

  DateTime? get lastSync => StorageService.instance.getLastSync('appartements_last_sync');

  // ==================== WRITE ====================

  Future<void> saveAll(List<Appartement> appartements) async {
    await _box.clear();
    for (final appart in appartements) {
      if (appart.id != null) {
        await _box.put(appart.id, appart);
      }
    }
    await StorageService.instance.setLastSync('appartements_last_sync');
  }

  Future<void> save(Appartement appartement) async {
    if (appartement.id != null) {
      await _box.put(appartement.id, appartement);
    }
  }

  Future<void> delete(int id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
```

#### 3.3 ChargeRepository (fusionné)

**Fichier**: `lib/repository/charge_repository.dart`

```dart
import 'package:hive/hive.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/service/storage/storage_service.dart';

class ChargeRepository {
  // Singleton
  static final ChargeRepository _instance = ChargeRepository._internal();
  factory ChargeRepository() => _instance;
  ChargeRepository._internal();

  Box<Charge> get _box => StorageService.instance.chargesBox;

  // ==================== READ ====================

  List<Charge> getAll() {
    return _box.values.toList();
  }

  Charge? getById(int id) {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Charge> getByAppartementId(int appartementId) {
    return _box.values.where((c) => c.appartementId == appartementId).toList();
  }

  List<Charge> getByResidenceId(int residenceId) {
    return _box.values.where((c) => c.residenceId == residenceId).toList();
  }

  bool get hasData => _box.isNotEmpty;

  DateTime? get lastSync => StorageService.instance.getLastSync('charges_last_sync');

  // ==================== WRITE ====================

  Future<void> saveAll(List<Charge> charges) async {
    await _box.clear();
    for (final charge in charges) {
      if (charge.id != null) {
        await _box.put(charge.id, charge);
      }
    }
    await StorageService.instance.setLastSync('charges_last_sync');
  }

  Future<void> save(Charge charge) async {
    if (charge.id != null) {
      await _box.put(charge.id, charge);
    }
  }

  Future<void> delete(int id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
```

---

### Phase 4 : Modifier les BLoCs (Pattern Cache-First)

#### 4.1 ResidenceBloc

**Fichier**: `lib/bloc/residence_bloc/residence_bloc.dart`

```dart
class ResidenceBloc extends Bloc<ResidenceEvent, ResidenceState> {
  final ResidenceRepository _repository = ResidenceRepository();
  final ResidenceService _service = ResidenceService();

  ResidenceBloc() : super(ResidenceInitial()) {
    on<LoadResidences>(_onLoadResidences);
    on<RefreshResidences>(_onRefreshResidences);
    // ... autres handlers
  }

  Future<void> _onLoadResidences(
    LoadResidences event,
    Emitter<ResidenceState> emit,
  ) async {
    emit(ResidenceLoading());

    // 1. Charger depuis le cache Hive (instantané)
    if (_repository.hasData) {
      final cachedResidences = _repository.getAll();
      emit(ResidencesLoaded(residences: cachedResidences, fromCache: true));
    }

    // 2. Fetch depuis l'API en arrière-plan
    try {
      final apiResidences = await _service.getProprietaireResidences();

      // 3. Sync vers le cache Hive
      await _repository.saveAll(apiResidences);

      // 4. Émettre les données fraîches
      emit(ResidencesLoaded(residences: apiResidences, fromCache: false));
    } catch (e) {
      // Si erreur API et pas de cache, émettre erreur
      if (!_repository.hasData) {
        emit(ResidenceError(message: e.toString()));
      }
      // Sinon, garder les données du cache (déjà émises)
    }
  }

  Future<void> _onRefreshResidences(
    RefreshResidences event,
    Emitter<ResidenceState> emit,
  ) async {
    // Force le rechargement depuis l'API
    try {
      final apiResidences = await _service.getProprietaireResidences();
      await _repository.saveAll(apiResidences);
      emit(ResidencesLoaded(residences: apiResidences, fromCache: false));
    } catch (e) {
      emit(ResidenceError(message: e.toString()));
    }
  }
}
```

#### 4.2 État avec indicateur de source

**Fichier**: `lib/bloc/residence_bloc/residence_state.dart`

```dart
class ResidencesLoaded extends ResidenceState {
  final List<Residence> residences;
  final bool fromCache; // Indique si les données viennent du cache

  const ResidencesLoaded({
    required this.residences,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [residences, fromCache];
}
```

---

### Phase 5 : Modifier les Preload Executors

**Fichier**: `lib/service/preload/executors/residence_preload_executor.dart`

```dart
class ResidencePreloadExecutor implements PreloadExecutor {
  final ResidenceBloc _residenceBloc;
  final ResidenceRepository _repository = ResidenceRepository();

  ResidencePreloadExecutor(this._residenceBloc);

  @override
  Future<void> execute() async {
    // Si déjà chargé, ne pas recharger
    if (_residenceBloc.state is ResidencesLoaded) {
      return;
    }

    // Déclencher le chargement (cache-first dans le bloc)
    _residenceBloc.add(const LoadResidences());

    // Attendre que les données soient chargées (cache ou API)
    await _residenceBloc.stream.firstWhere(
      (state) => state is ResidencesLoaded || state is ResidenceError,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => _residenceBloc.state,
    );
  }
}
```

---

### Phase 6 : Nettoyage

#### 6.1 Supprimer les fichiers obsolètes

```bash
# Supprimer
rm lib/service/comptabilite/charge_local_service.dart
rm lib/repository/proprio_repository.dart
```

#### 6.2 Mettre à jour les imports

Rechercher et remplacer dans tout le projet :
- `ChargeLocalService` → `ChargeRepository`
- `ProprioRepository` → `ResidenceRepository` / `AppartementRepository`

---

## Diagramme de séquence

```
┌─────────┐     ┌─────────┐     ┌────────────┐     ┌─────────┐     ┌─────────┐
│   UI    │     │  Bloc   │     │ Repository │     │ Service │     │ Serveur │
└────┬────┘     └────┬────┘     └─────┬──────┘     └────┬────┘     └────┬────┘
     │               │                │                 │               │
     │ LoadResidences│                │                 │               │
     │──────────────▶│                │                 │               │
     │               │                │                 │               │
     │               │   getAll()     │                 │               │
     │               │───────────────▶│                 │               │
     │               │                │                 │               │
     │               │◀──────────────┤│ [Cache Hive]   │               │
     │               │                │                 │               │
     │◀──────────────│ emit(Loaded,   │                 │               │
     │               │   fromCache)   │                 │               │
     │               │                │                 │               │
     │ [UI affichée] │                │                 │               │
     │               │                │   fetch()       │               │
     │               │                │────────────────▶│  GET /api     │
     │               │                │                 │──────────────▶│
     │               │                │                 │               │
     │               │                │                 │◀──────────────│
     │               │                │◀────────────────│               │
     │               │                │                 │               │
     │               │   saveAll()    │                 │               │
     │               │───────────────▶│                 │               │
     │               │                │ [Sync Hive]     │               │
     │               │                │                 │               │
     │◀──────────────│ emit(Loaded,   │                 │               │
     │               │   fresh)       │                 │               │
     │               │                │                 │               │
     │ [UI mise à jour si changements]│                 │               │
     │               │                │                 │               │
```

---

## TypeAdapters - IDs réservés

| Type ID | Modèle | Fichier |
|---------|--------|---------|
| 0 | Conversation | `conversation.dart` (existant) |
| 1 | ChatMessage | `chat_message.dart` (existant) |
| 2 | User | `user.dart` (existant) |
| 3 | Residence | `residence.dart` (nouveau) |
| 4 | Appartement | `appart.dart` (nouveau) |
| 5 | Address | `address.dart` (nouveau) |
| 6 | Charge | `charge.dart` (nouveau) |
| 7 | PhotoAppart | `photo_appart.dart` (optionnel) |
| 8 | Remise | `remise.dart` (optionnel) |

---

## Checklist d'implémentation

### Phase 1 : TypeAdapters
- [ ] Vérifier dépendances hive_generator dans pubspec.yaml
- [ ] Annoter `Residence` avec `@HiveType(typeId: 3)`
- [ ] Annoter `Appartement` avec `@HiveType(typeId: 4)`
- [ ] Annoter `Address` avec `@HiveType(typeId: 5)`
- [ ] Annoter `Charge` avec `@HiveType(typeId: 6)`
- [ ] Exécuter `flutter pub run build_runner build`

### Phase 2 : StorageService
- [ ] Enregistrer les nouveaux adapters
- [ ] Créer les nouvelles boxes
- [ ] Ajouter méthodes de métadonnées sync

### Phase 3 : Repositories
- [ ] Créer `ResidenceRepository`
- [ ] Créer `AppartementRepository`
- [ ] Refactorer `ChargeRepository`

### Phase 4 : BLoCs
- [ ] Modifier `ResidenceBloc` (cache-first)
- [ ] Modifier `AppartementBloc` (cache-first)
- [ ] Modifier `ChargeBloc` (cache-first)
- [ ] Ajouter `fromCache` aux états

### Phase 5 : Preload
- [ ] Modifier `ResidencePreloadExecutor`
- [ ] Modifier `AppartementPreloadExecutor`
- [ ] Créer `ChargePreloadExecutor` si nécessaire

### Phase 6 : Nettoyage
- [ ] Supprimer `ChargeLocalService`
- [ ] Supprimer `ProprioRepository`
- [ ] Mettre à jour tous les imports
- [ ] Tester le flow complet

---

## Notes importantes

1. **Ordre d'enregistrement des adapters** : Les dépendances doivent être enregistrées avant les types qui les utilisent (ex: `Address` avant `Residence`)

2. **Migration des données existantes** : Si des données existent déjà dans l'ancien format, prévoir une migration

3. **Gestion des conflits** : En cas de conflit entre cache et API, l'API est la source de vérité

4. **Nettoyage du cache** : Prévoir un mécanisme pour vider le cache à la déconnexion

5. **Taille du cache** : Surveiller la taille des boxes Hive en production
