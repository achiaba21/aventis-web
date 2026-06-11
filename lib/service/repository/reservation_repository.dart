import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Résultat du chargement des réservations avec indication de la source
class ReservationResult {
  final List<Reservation> reservations;
  final bool isFromCache;

  ReservationResult({required this.reservations, required this.isFromCache});
}

/// Repository pour les réservations - gère le cache Hive et les appels API
///
/// Pattern cache-first :
/// 1. Retourne les données du cache immédiatement
/// 2. Rafraîchit depuis l'API en arrière-plan
/// 3. Met à jour le cache avec les nouvelles données
class ReservationRepository {
  // Singleton
  static final ReservationRepository _instance = ReservationRepository._internal();
  factory ReservationRepository() => _instance;
  ReservationRepository._internal();

  // Services
  final StorageService _storage = StorageService.instance;
  final ReservationService _apiService = ReservationService();

  // ==================== VERSIONING DU CACHE (PERF-04) ====================

  /// Version du schéma de cache. À incrémenter à chaque changement de
  /// structure du modèle [Reservation] : les caches existants seront purgés
  /// au premier accès.
  static const int cacheVersion = 1;

  static const String _cacheVersionKey = 'cache_version_reservations';
  bool _versionChecked = false;

  /// Purge les caches si leur version stockée diffère de [cacheVersion].
  /// Mémoïsé : ne coûte qu'une lecture par session.
  Future<void> _ensureCacheVersion() async {
    if (_versionChecked) return;
    _versionChecked = true;
    final stored = _storage.getAppSetting<int>(_cacheVersionKey);
    if (stored != cacheVersion) {
      if (stored != null) {
        deboger('[ReservationRepository] Version de cache $stored → '
            '$cacheVersion : purge');
        await clearAllCaches();
      }
      await _storage.setAppSetting<int>(_cacheVersionKey, cacheVersion);
    }
  }

  /// Récupère les réservations locataire depuis le cache local
  List<Reservation> getCachedUserReservations() {
    try {
      final reservationsData = _storage.getReservations();
      if (reservationsData.isEmpty) return [];

      return reservationsData.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      deboger(['[ReservationRepository] Erreur getCachedUserReservations: $e']);
      return [];
    }
  }

  /// Récupère les réservations propriétaire depuis le cache local (clé séparée)
  List<Reservation> getCachedProprietaireReservations() {
    try {
      final reservationsData = _storage.getProprioReservations();
      if (reservationsData.isEmpty) return [];

      return reservationsData.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      deboger(['[ReservationRepository] Erreur getCachedProprietaireReservations: $e']);
      return [];
    }
  }

  /// Récupère les réservations du propriétaire depuis l'API et met à jour le cache proprio
  Future<List<Reservation>> fetchAndCacheProprietaireReservations() async {
    try {
      final reservations = await _apiService.getProprietaireReservations();

      // Sauvegarder dans le cache proprio (clé séparée)
      final reservationsJson = reservations.map((r) => r.toJson()).toList();
      await _storage.saveProprioReservations(reservationsJson);

      deboger(['[ReservationRepository] ${reservations.length} réservations proprio mises en cache']);
      return reservations;
    } catch (e) {
      deboger(['[ReservationRepository] Erreur fetchAndCacheProprietaireReservations: $e']);
      rethrow;
    }
  }

  /// Récupère les réservations de l'utilisateur depuis l'API et met à jour le cache user
  Future<List<Reservation>> fetchAndCacheUserReservations() async {
    try {
      final reservations = await _apiService.getUserReservations();

      // Sauvegarder dans le cache user (clé séparée)
      final reservationsJson = reservations.map((r) => r.toJson()).toList();
      await _storage.saveReservations(reservationsJson);

      deboger(['[ReservationRepository] ${reservations.length} réservations user mises en cache']);
      return reservations;
    } catch (e) {
      deboger(['[ReservationRepository] Erreur fetchAndCacheUserReservations: $e']);
      rethrow;
    }
  }

  /// Récupère les réservations du propriétaire avec pattern cache-first
  ///
  /// Retourne immédiatement les données du cache si disponibles,
  /// puis rafraîchit depuis l'API en arrière-plan.
  ///
  /// Retourne un [ReservationResult] avec indication de la source (cache ou API)
  Future<ReservationResult> getProprietaireReservations({
    bool forceRefresh = false,
    Function(List<Reservation>)? onApiData,
  }) async {
    await _ensureCacheVersion();
    // Si force refresh, aller directement à l'API avec fallback au cache proprio
    if (forceRefresh) {
      try {
        final reservations = await fetchAndCacheProprietaireReservations();
        return ReservationResult(reservations: reservations, isFromCache: false);
      } catch (e) {
        // En cas d'erreur, retourner le cache proprio si disponible
        final cached = getCachedProprietaireReservations();
        deboger(['[ReservationRepository] Force refresh échoué - retour du cache proprio']);
        return ReservationResult(reservations: cached, isFromCache: true);
      }
    }

    // Récupérer depuis le cache proprio
    final cached = getCachedProprietaireReservations();

    // Si cache vide, aller à l'API directement
    if (cached.isEmpty) {
      try {
        final reservations = await fetchAndCacheProprietaireReservations();
        return ReservationResult(reservations: reservations, isFromCache: false);
      } catch (e) {
        // Mode offline avec cache vide : retourner liste vide sans erreur
        deboger(['[ReservationRepository] API échoué, cache proprio vide - retour liste vide']);
        return ReservationResult(reservations: [], isFromCache: true);
      }
    }

    // Cache frais (TTL 15 min, PERF-04) : aucun appel API ;
    // périmé : rafraîchissement en arrière-plan
    if (isCacheStale(isProprietaire: true)) {
      _refreshProprietaireInBackground(onApiData);
    }

    return ReservationResult(reservations: cached, isFromCache: true);
  }

  /// Récupère les réservations de l'utilisateur avec pattern cache-first
  ///
  /// Retourne immédiatement les données du cache si disponibles,
  /// puis rafraîchit depuis l'API en arrière-plan.
  Future<ReservationResult> getUserReservations({
    bool forceRefresh = false,
    Function(List<Reservation>)? onApiData,
  }) async {
    await _ensureCacheVersion();
    // Si force refresh, aller directement à l'API avec fallback au cache user
    if (forceRefresh) {
      try {
        final reservations = await fetchAndCacheUserReservations();
        return ReservationResult(reservations: reservations, isFromCache: false);
      } catch (e) {
        // En cas d'erreur, retourner le cache user si disponible
        final cached = getCachedUserReservations();
        deboger(['[ReservationRepository] Force refresh échoué - retour du cache user']);
        return ReservationResult(reservations: cached, isFromCache: true);
      }
    }

    // Récupérer depuis le cache user
    final cached = getCachedUserReservations();

    // Si cache vide, aller à l'API directement
    if (cached.isEmpty) {
      try {
        final reservations = await fetchAndCacheUserReservations();
        return ReservationResult(reservations: reservations, isFromCache: false);
      } catch (e) {
        // Mode offline avec cache vide : retourner liste vide sans erreur
        deboger(['[ReservationRepository] API échoué, cache user vide - retour liste vide']);
        return ReservationResult(reservations: [], isFromCache: true);
      }
    }

    // Cache frais (TTL 15 min, PERF-04) : aucun appel API ;
    // périmé : rafraîchissement en arrière-plan
    if (isCacheStale()) {
      _refreshUserInBackground(onApiData);
    }

    return ReservationResult(reservations: cached, isFromCache: true);
  }

  /// Récupère une page supplémentaire de réservations (PERF-02)
  ///
  /// Appel API direct, jamais mis en cache (seule la première page vit dans
  /// Hive). Si le backend ne pagine pas encore, il renvoie la liste complète :
  /// l'appelant dédoublonne et conclut à la fin de liste (CA1).
  Future<List<Reservation>> fetchMoreReservations(
    int page, {
    int size = 30,
    bool isProprietaire = false,
  }) {
    return isProprietaire
        ? _apiService.getProprietaireReservations(page: page, size: size)
        : _apiService.getUserReservations(page: page, size: size);
  }

  /// Rafraîchit les réservations propriétaire en arrière-plan
  void _refreshProprietaireInBackground(Function(List<Reservation>)? onApiData) {
    fetchAndCacheProprietaireReservations().then((reservations) {
      if (onApiData != null) {
        onApiData(reservations);
      }
    }).catchError((e) {
      deboger(['[ReservationRepository] Erreur refresh proprio background: $e']);
    });
  }

  /// Rafraîchit les réservations utilisateur en arrière-plan
  void _refreshUserInBackground(Function(List<Reservation>)? onApiData) {
    fetchAndCacheUserReservations().then((reservations) {
      if (onApiData != null) {
        onApiData(reservations);
      }
    }).catchError((e) {
      deboger(['[ReservationRepository] Erreur refresh user background: $e']);
    });
  }

  /// Récupère une réservation par sa référence (deep-link, push notif, card chat).
  ///
  /// Pattern cache-first : si la réservation est présente dans l'un des deux
  /// caches (user ou proprio), elle est retournée immédiatement avec
  /// `isFromCache: true` ; un fetch API tourne en arrière-plan et appelle
  /// `onApiData` quand la version fraîche arrive. Si rien en cache, fetch
  /// direct API.
  Future<ReservationResult> getByReference(
    String reference, {
    Function(Reservation)? onApiData,
  }) async {
    final cached = _findCachedByReference(reference);

    if (cached == null) {
      try {
        final fresh = await _apiService.getByReference(reference);
        return ReservationResult(reservations: [fresh], isFromCache: false);
      } catch (e) {
        deboger(['[ReservationRepository] getByReference API échoué: $e']);
        return ReservationResult(reservations: const [], isFromCache: true);
      }
    }

    _refreshByReferenceInBackground(reference, onApiData);
    return ReservationResult(reservations: [cached], isFromCache: true);
  }

  Reservation? _findCachedByReference(String reference) {
    final ref = reference.trim();
    if (ref.isEmpty) return null;
    for (final r in getCachedUserReservations()) {
      if (r.reference == ref) return r;
    }
    for (final r in getCachedProprietaireReservations()) {
      if (r.reference == ref) return r;
    }
    return null;
  }

  void _refreshByReferenceInBackground(
    String reference,
    Function(Reservation)? onApiData,
  ) {
    _apiService.getByReference(reference).then((fresh) {
      if (onApiData != null) onApiData(fresh);
    }).catchError((e) {
      deboger(['[ReservationRepository] Erreur refresh byRef background: $e']);
    });
  }

  /// Récupère la date de dernière synchronisation du cache locataire
  DateTime? getUserLastSyncDate() {
    return _storage.getReservationsLastSync();
  }

  /// Récupère la date de dernière synchronisation du cache propriétaire
  DateTime? getProprietaireLastSyncDate() {
    return _storage.getProprioReservationsLastSync();
  }

  /// Vérifie si le cache est périmé (TTL par défaut : 15 min, PERF-04)
  bool isCacheStale({
    Duration maxAge = const Duration(minutes: 15),
    bool isProprietaire = false,
  }) {
    final lastSync = isProprietaire ? getProprietaireLastSyncDate() : getUserLastSyncDate();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) >= maxAge;
  }

  /// Vide le cache des réservations locataire
  Future<void> clearUserCache() async {
    await _storage.clearReservations();
    deboger('[ReservationRepository] Cache user vidé');
  }

  /// Vide le cache des réservations propriétaire
  Future<void> clearProprietaireCache() async {
    await _storage.clearProprioReservations();
    deboger('[ReservationRepository] Cache proprio vidé');
  }

  /// Vide les deux caches de réservations
  Future<void> clearAllCaches() async {
    await Future.wait([clearUserCache(), clearProprietaireCache()]);
    deboger('[ReservationRepository] Tous les caches vidés');
  }
}
