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

  /// Récupère les appartements avec pattern cache-first.
  ///
  /// Retourne immédiatement les données du cache si disponibles,
  /// puis rafraîchit depuis l'API en arrière-plan.
  Future<List<Appartement>> getAppartements({
    bool forceRefresh = false,
    Function(List<Appartement>)? onApiData,
  }) async {
    if (forceRefresh) {
      return fetchAndCacheAppartements();
    }

    final cached = getCachedAppartements();
    if (cached.isEmpty) {
      return fetchAndCacheAppartements();
    }

    _refreshInBackground(onApiData);
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

  /// Récupère le feed locataire avec pattern cache-first (cache Hive →
  /// API en background). Source : endpoint public `auth/appartement/apparts`.
  Future<List<Appartement>> getAllAppartements({
    bool forceRefresh = false,
    Function(List<Appartement>)? onApiData,
  }) async {
    if (forceRefresh) return fetchAndCacheAllAppartements();
    final cached = getCachedAllAppartements();
    if (cached.isEmpty) return fetchAndCacheAllAppartements();
    _refreshAllInBackground(onApiData);
    return cached;
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

  /// Récupère la date de dernière synchronisation
  DateTime? getLastSyncDate() {
    return _storage.getAppartementsLastSync();
  }

  /// Vérifie si le cache est périmé (plus de X heures)
  bool isCacheStale({int maxAgeHours = 24}) {
    final lastSync = getLastSyncDate();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inHours >= maxAgeHours;
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
