import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/model/appartement/appartement_backend_mapper.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/model/forms/uploaded_image.dart';

/// Repository pour les appartements - gère le cache Hive et les appels API.
///
/// Pattern cache-first :
/// 1. Retourne les données du cache immédiatement
/// 2. Rafraîchit depuis l'API en arrière-plan
/// 3. Met à jour le cache avec les nouvelles données
///
/// Orchestre [AppartementBackendMapper] pour la couche legacy résidence
/// (à l'envoi : embarque la "shape résidence" ; à la réception : extrait
/// l'address). Maintient en mémoire un cache `appartId → backendResidenceId`
/// utilisé pour préserver la cohérence des updates côté serveur.
class AppartementRepository {
  // Singleton
  static final AppartementRepository _instance = AppartementRepository._internal();
  factory AppartementRepository() => _instance;
  AppartementRepository._internal();

  // Services
  final StorageService _storage = StorageService.instance;
  final AppartementService _apiService = AppartementService();
  final AppartementBackendMapper _mapper = AppartementBackendMapper.instance;

  /// Cache mémoire `appartId → backendResidenceId` pour préserver la
  /// cohérence des updates côté backend (qui attend toujours l'ID de la
  /// résidence parente). Rempli à la lecture, consommé à la mise à jour.
  ///
  /// Sera retiré quand BACKEND-FLAT-APPART aura abouti.
  final Map<int, int> _backendResidenceIds = {};

  // ==================== VERSIONING DU CACHE (PERF-04) ====================

  /// Version du schéma de cache. À incrémenter à chaque changement de
  /// structure du modèle [Appartement] : le cache existant sera purgé au
  /// premier accès (jamais de parsing d'un schéma périmé).
  static const int cacheVersion = 1;

  static const String _cacheVersionKey = 'cache_version_appartements';
  bool _versionChecked = false;

  /// Purge le cache si sa version stockée diffère de [cacheVersion].
  /// Mémoïsé : ne coûte qu'une lecture par session.
  Future<void> _ensureCacheVersion() async {
    if (_versionChecked) return;
    _versionChecked = true;
    final stored = _storage.getAppSetting<int>(_cacheVersionKey);
    if (stored != cacheVersion) {
      if (stored != null) {
        deboger('[AppartementRepository] Version de cache $stored → '
            '$cacheVersion : purge');
        await clearCache();
      }
      await _storage.setAppSetting<int>(_cacheVersionKey, cacheVersion);
    }
  }

  /// Récupère les appartements depuis le cache local.
  List<Appartement> getCachedAppartements() {
    try {
      final appartementsData = _storage.getAppartements();
      if (appartementsData.isEmpty) return [];
      return appartementsData.map((json) => Appartement.fromJson(json)).toList();
    } catch (e) {
      deboger(['[AppartementRepository] Erreur getCachedAppartements: $e']);
      return [];
    }
  }

  /// Récupère les appartements du propriétaire depuis l'API et met à jour le cache.
  Future<List<Appartement>> fetchAndCacheAppartements() async {
    try {
      final appartements = await _apiService.getProprietaireAppartements();

      // Sauvegarder dans le cache
      final appartementsJson = appartements.map((a) => a.toJson()).toList();
      await _storage.saveAppartements(appartementsJson);

      deboger(['[AppartementRepository] ${appartements.length} appartements mis en cache']);
      return appartements;
    } catch (e) {
      deboger(['[AppartementRepository] Erreur fetchAndCacheAppartements: $e']);
      rethrow;
    }
  }

  /// Récupère les appartements avec pattern cache-first + TTL (PERF-04).
  ///
  /// - Cache présent et frais (< [maxAge]) : retour cache, AUCUN appel API.
  /// - Cache présent mais périmé : retour cache immédiat + refresh en
  ///   arrière-plan (via [onApiData]).
  /// - Cache vide ou [forceRefresh] : appel API direct.
  Future<List<Appartement>> getAppartements({
    bool forceRefresh = false,
    Function(List<Appartement>)? onApiData,
  }) async {
    await _ensureCacheVersion();
    if (forceRefresh) {
      return fetchAndCacheAppartements();
    }

    final cached = getCachedAppartements();
    if (cached.isEmpty) {
      return fetchAndCacheAppartements();
    }

    if (isCacheStale()) {
      _refreshInBackground(onApiData);
    }
    return cached;
  }

  /// Rafraîchit les données en arrière-plan
  void _refreshInBackground(Function(List<Appartement>)? onApiData) {
    fetchAndCacheAppartements().then((appartements) {
      if (onApiData != null) {
        onApiData(appartements);
      }
    }).catchError((e) {
      deboger(['[AppartementRepository] Erreur refresh background: $e']);
    });
  }

  // ==================== FEED LOCATAIRE (endpoint public) ====================

  /// Récupère le feed locataire depuis le cache Hive (clé distincte du proprio).
  List<Appartement> getCachedAllAppartements() {
    try {
      final data = _storage.getAppartementsLocataire();
      if (data.isEmpty) return [];
      return data.map((json) => Appartement.fromJson(json)).toList();
    } catch (e) {
      deboger(['[AppartementRepository] Erreur getCachedAllAppartements: $e']);
      return [];
    }
  }

  /// Fetch le feed locataire depuis l'endpoint public et met à jour le cache.
  Future<List<Appartement>> fetchAndCacheAllAppartements() async {
    try {
      final appartements = await _apiService.getAppartements();
      final json = appartements.map((a) => a.toJson()).toList();
      await _storage.saveAppartementsLocataire(json);
      deboger([
        '[AppartementRepository] ${appartements.length} appartements feed locataire mis en cache'
      ]);
      return appartements;
    } catch (e) {
      deboger(['[AppartementRepository] Erreur fetchAndCacheAllAppartements: $e']);
      rethrow;
    }
  }

  /// Récupère le feed locataire avec pattern cache-first + TTL (PERF-04).
  /// Source : endpoint public `auth/appartement/apparts`.
  ///
  /// Cache frais (< 1 h) : aucun appel API ; périmé : cache immédiat +
  /// refresh arrière-plan ; vide ou [forceRefresh] : API directe.
  Future<List<Appartement>> getAllAppartements({
    bool forceRefresh = false,
    Function(List<Appartement>)? onApiData,
  }) async {
    await _ensureCacheVersion();
    if (forceRefresh) return fetchAndCacheAllAppartements();
    final cached = getCachedAllAppartements();
    if (cached.isEmpty) return fetchAndCacheAllAppartements();
    if (isFeedCacheStale()) {
      _refreshAllInBackground(onApiData);
    }
    return cached;
  }

  /// Récupère une page supplémentaire du feed locataire (PERF-02).
  ///
  /// Appel API direct, jamais mis en cache (seule la première page vit dans
  /// Hive). Si le backend ne pagine pas encore, il renvoie la liste complète :
  /// l'appelant dédoublonne par id et conclut à la fin de liste (CA1).
  Future<List<Appartement>> fetchMoreAppartements(int page, {int size = 30}) {
    return _apiService.getAppartements(page: page, size: size);
  }

  void _refreshAllInBackground(Function(List<Appartement>)? onApiData) {
    fetchAndCacheAllAppartements().then((appartements) {
      if (onApiData != null) onApiData(appartements);
    }).catchError((e) {
      deboger(['[AppartementRepository] Erreur refresh feed background: $e']);
    });
  }

  /// Récupère un appartement par ID depuis le cache
  Appartement? getCachedAppartementById(int id) {
    final cached = getCachedAppartements();
    try {
      return cached.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Récupère un appartement par ID (cache puis API si non trouvé)
  Future<Appartement> getAppartementById(int id) async {
    final cached = getCachedAppartementById(id);
    if (cached != null) {
      return cached;
    }
    return _apiService.getAppartementById(id);
  }

  /// Crée un appartement (sans images) et met à jour le cache.
  Future<Appartement> saveAppartement(Appartement appartement) async {
    final payload = _mapper.toCreatePayload(appartement);
    final responseMap = await _apiService.saveAppartement(payload);
    return _persistAndReturn(responseMap);
  }

  /// Crée un appartement avec images et met à jour le cache.
  Future<Appartement> createAppartementWithImages(
    Appartement appartement,
    List<UploadedImage> images,
  ) async {
    final payload = _mapper.toCreatePayload(appartement);
    final responseMap = await _apiService.saveAppartementWithImages(payload, images);
    final saved = _persistAndReturn(responseMap);
    deboger(['[AppartementRepository] Appartement créé avec images: ${saved.id}']);
    return saved;
  }

  /// Met à jour un appartement avec images et le cache.
  ///
  /// Récupère le `backendResidenceId` depuis le cache mémoire pour préserver
  /// la cohérence backend.
  Future<Appartement> updateAppartementWithImages(
    int appartementId,
    Appartement appartement,
    List<UploadedImage> images, {
    List<String>? photosToDelete,
  }) async {
    final backendResidenceId = _backendResidenceIds[appartementId];
    final payload = _mapper.toUpdatePayload(
      appartement,
      backendResidenceId: backendResidenceId,
    );
    final responseMap = await _apiService.updateAppartementWithImages(
      appartementId,
      payload,
      images,
      photosToDelete: photosToDelete,
    );
    final updated = _persistAndReturn(responseMap);
    deboger(['[AppartementRepository] Appartement mis à jour avec images: ${updated.id}']);
    return updated;
  }

  /// Supprime un appartement et met à jour le cache.
  Future<void> deleteAppartement(int id) async {
    await _apiService.deleteAppartement(id);

    final cached = getCachedAppartements();
    cached.removeWhere((a) => a.id == id);
    await _storage.saveAppartements(cached.map((a) => a.toJson()).toList());
    _backendResidenceIds.remove(id);
  }

  // ==================== Modération (actions propriétaire) ====================

  /// Met l'annonce hors ligne (EN_LIGNE → HORS_LIGNE) et met à jour le cache.
  Future<Appartement> mettreHorsLigne(int id) async {
    return _persistAndReturn(await _apiService.mettreHorsLigne(id));
  }

  /// Remet l'annonce en ligne (HORS_LIGNE → EN_LIGNE) et met à jour le cache.
  Future<Appartement> remettreEnLigne(int id) async {
    return _persistAndReturn(await _apiService.remettreEnLigne(id));
  }

  /// Resoumet l'annonce refusée (REFUSER → EN_COURS) et met à jour le cache.
  Future<Appartement> resoumettre(int id) async {
    return _persistAndReturn(await _apiService.resoumettre(id));
  }

  /// Récupère la date de dernière synchronisation
  DateTime? getLastSyncDate() {
    return _storage.getAppartementsLastSync();
  }

  /// Vérifie si le cache proprio est périmé (TTL par défaut : 1 h, PERF-04)
  bool isCacheStale({int maxAgeHours = 1}) {
    return _isStale(getLastSyncDate(), maxAgeHours);
  }

  /// Vérifie si le cache du feed locataire est périmé (TTL : 1 h, PERF-04)
  bool isFeedCacheStale({int maxAgeHours = 1}) {
    return _isStale(_storage.getAppartementsLocataireLastSync(), maxAgeHours);
  }

  bool _isStale(DateTime? lastSync, int maxAgeHours) {
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inHours >= maxAgeHours;
  }

  /// Vide les caches (proprio + feed locataire).
  Future<void> clearCache() async {
    await _storage.clearAppartements();
    await _storage.clearAppartementsLocataire();
    _backendResidenceIds.clear();
    deboger('[AppartementRepository] Caches vidés (proprio + locataire)');
  }

  // ============== Helpers privés ==============

  /// Parse la réponse backend, met à jour le cache d'IDs résidence
  /// puis upsert dans le cache des appartements.
  Appartement _persistAndReturn(Map<String, dynamic> responseMap) {
    final saved = _mapper.fromBackendDto(responseMap);

    // Mémoriser l'ID résidence backend pour les updates futurs
    final backendResidenceId = _mapper.extractBackendResidenceId(responseMap);
    if (saved.id != null && backendResidenceId != null) {
      _backendResidenceIds[saved.id!] = backendResidenceId;
    }

    // Upsert dans le cache local
    final cached = getCachedAppartements();
    final existingIndex = cached.indexWhere((a) => a.id == saved.id);
    if (existingIndex != -1) {
      cached[existingIndex] = saved;
    } else {
      cached.add(saved);
    }
    _storage.saveAppartements(cached.map((a) => a.toJson()).toList());

    return saved;
  }
}
