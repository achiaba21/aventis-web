import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/storage/secure_storage_service.dart';
import 'package:asfar/util/function.dart';

/// Service de stockage local centralisé utilisant Hive
///
/// Toutes les boxes sont chiffrées (HiveAesCipher) avec une clé AES détenue
/// par [SecureStorageService]. Le jeton de session ne transite plus par Hive :
/// il est délégué au stockage sécurisé de l'OS.
///
/// Suit les principes :
/// - Single Responsibility : Gère uniquement le stockage persistant
/// - DRY : Source unique pour toutes les opérations de stockage
/// - Singleton : Une seule instance dans toute l'application
class StorageService {
  static StorageService? _instance;

  // Noms des boxes Hive
  static const String _authBoxName = 'authBox';
  static const String _userBoxName = 'userBox';
  static const String _chargesBoxName = 'chargesBox';
  static const String _residencesBoxName = 'residencesBox';
  static const String _appartementsBoxName = 'appartementsBox';
  static const String _proprietairesBoxName = 'proprietairesBox';
  static const String _reservationsBoxName = 'reservationsBox';
  static const String _appartementDraftBoxName = 'appartementDraftBox';
  static const String _appSettingsBoxName = 'appSettingsBox';

  // Clés de stockage
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _chargesKey = 'charges';
  static const String _chargesLastIdKey = 'charges_last_id';
  static const String _residencesKey = 'residences';
  static const String _residencesLastSyncKey = 'residences_last_sync';
  static const String _appartementsKey = 'appartements';
  static const String _appartementsLastSyncKey = 'appartements_last_sync';
  static const String _appartementsLocataireKey = 'appartements_locataire';
  static const String _appartementsLocataireLastSyncKey = 'appartements_locataire_last_sync';
  static const String _proprietairesKey = 'proprietaires';
  static const String _reservationsKey = 'reservations';
  static const String _reservationsLastSyncKey = 'reservations_last_sync';
  static const String _proprioReservationsKey = 'proprio_reservations';
  static const String _proprioReservationsLastSyncKey = 'proprio_reservations_last_sync';

  // Boxes Hive
  late Box _authBox;
  late Box _userBox;
  late Box _chargesBox;
  late Box _residencesBox;
  late Box _appartementsBox;
  late Box _proprietairesBox;
  late Box _reservationsBox;
  late Box _appartementDraftBox;
  late Box _appSettingsBox;

  bool _isInitialized = false;

  /// Singleton instance
  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  StorageService._internal();

  /// Initialise Hive et ouvre les boxes nécessaires
  ///
  /// Doit être appelé au démarrage de l'application (dans main.dart)
  /// après Hive.initFlutter()
  Future<void> init() async {
    if (_isInitialized) {
      deboger("StorageService déjà initialisé");
      return;
    }

    try {
      // Clé AES détenue par le stockage sécurisé de l'OS
      final hiveKey = await SecureStorageService.instance.getOrCreateHiveKey();
      final cipher = HiveAesCipher(hiveKey);

      // Ouvrir les boxes (chiffrées, avec purge si illisibles)
      _authBox = await _openBoxSafely(_authBoxName, cipher);
      _userBox = await _openBoxSafely(_userBoxName, cipher);
      _chargesBox = await _openBoxSafely(_chargesBoxName, cipher);
      _residencesBox = await _openBoxSafely(_residencesBoxName, cipher);
      _appartementsBox = await _openBoxSafely(_appartementsBoxName, cipher);
      _proprietairesBox = await _openBoxSafely(_proprietairesBoxName, cipher);
      _reservationsBox = await _openBoxSafely(_reservationsBoxName, cipher);
      _appartementDraftBox =
          await _openBoxSafely(_appartementDraftBoxName, cipher);
      _appSettingsBox = await _openBoxSafely(_appSettingsBoxName, cipher);

      // Purge du jeton historique stocké en clair dans authBox
      // (versions antérieures au chiffrement). Le jeton vit désormais
      // dans SecureStorageService uniquement.
      await _authBox.delete(_tokenKey);

      _isInitialized = true;
      deboger("StorageService initialisé avec succès");

      // Debug: Afficher le contenu actuel
      final token = getToken();
      final user = getUser();
      deboger([
        "StorageService - État initial:",
        "Token présent: ${token != null}",
        "User présent: ${user != null}"
      ]);
    } catch (e) {
      deboger(["Erreur lors de l'initialisation de StorageService:", e]);
      rethrow;
    }
  }

  /// Ouvre une box chiffrée en tolérant la corruption
  ///
  /// Une box illisible (ancienne box non chiffrée, clé AES régénérée,
  /// données corrompues) est purgée du disque puis rouverte vide : le cache
  /// se reconstruit depuis l'API et, au pire, l'utilisateur se reconnecte.
  /// Jamais de crash au démarrage.
  Future<Box> _openBoxSafely(String name, HiveAesCipher cipher) async {
    try {
      return await Hive.openBox(name, encryptionCipher: cipher);
    } catch (e) {
      deboger(["Box '$name' illisible, purge et réouverture:", e]);
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox(name, encryptionCipher: cipher);
    }
  }

  /// Vérifie que le service est initialisé
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'StorageService non initialisé. '
        'Appelez StorageService.instance.init() dans main.dart'
      );
    }
  }

  // ==================== TOKEN ====================
  // Le jeton est délégué à SecureStorageService (Keychain/Keystore).
  // Il ne touche plus aux boxes Hive.

  /// Sauvegarde le token d'authentification (stockage sécurisé OS)
  Future<void> saveToken(String token) async {
    await SecureStorageService.instance.saveToken(token);
    deboger("Token sauvegardé (stockage sécurisé)");
  }

  /// Récupère le token d'authentification (cache mémoire, synchrone)
  String? getToken() {
    return SecureStorageService.instance.cachedToken;
  }

  /// Supprime le token d'authentification
  Future<void> deleteToken() async {
    await SecureStorageService.instance.deleteToken();
    deboger("Token supprimé (stockage sécurisé)");
  }

  /// Vérifie si un token existe
  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== USER ====================

  /// Sauvegarde les données utilisateur
  ///
  /// Sérialise l'utilisateur en JSON avant de le stocker
  Future<void> saveUser(User user) async {
    _ensureInitialized();
    try {
      final userJson = jsonEncode(user.toJson());
      await _userBox.put(_userKey, userJson);
      // SEC-04 : pas de nom d'utilisateur dans les logs
      deboger(["User sauvegardé dans StorageService (#${user.id})"]);
    } catch (e) {
      deboger(["Erreur lors de la sauvegarde de l'utilisateur:", e]);
      rethrow;
    }
  }

  /// Récupère les données utilisateur
  ///
  /// Désérialise le JSON en objet User (avec gestion des sous-types)
  User? getUser() {
    _ensureInitialized();
    try {
      final userJson = _userBox.get(_userKey) as String?;
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJsonAll(userMap);
    } catch (e) {
      deboger(["Erreur lors de la récupération de l'utilisateur:", e]);
      return null;
    }
  }

  /// Supprime les données utilisateur
  Future<void> deleteUser() async {
    _ensureInitialized();
    await _userBox.delete(_userKey);
    deboger("User supprimé de StorageService");
  }

  /// Vérifie si un utilisateur existe
  bool hasUser() {
    _ensureInitialized();
    return _userBox.containsKey(_userKey);
  }

  // ==================== CHARGES ====================

  /// Récupère toutes les charges stockées
  List<Map<String, dynamic>> getCharges() {
    _ensureInitialized();
    try {
      final chargesData = _chargesBox.get(_chargesKey);
      if (chargesData == null) return [];

      // Convertir les données Hive en List<Map>
      final List<dynamic> chargesList = chargesData is String
          ? jsonDecode(chargesData)
          : List.from(chargesData);
      return chargesList.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur lors de la récupération des charges:", e]);
      return [];
    }
  }

  /// Sauvegarde toutes les charges
  Future<void> saveCharges(List<Map<String, dynamic>> charges) async {
    _ensureInitialized();
    await _chargesBox.put(_chargesKey, charges);
  }

  /// Récupère le dernier ID utilisé pour les charges
  int getChargesLastId() {
    _ensureInitialized();
    return _chargesBox.get(_chargesLastIdKey, defaultValue: 0) as int;
  }

  /// Met à jour le dernier ID des charges
  Future<void> setChargesLastId(int id) async {
    _ensureInitialized();
    await _chargesBox.put(_chargesLastIdKey, id);
  }

  /// Supprime toutes les charges
  Future<void> clearCharges() async {
    _ensureInitialized();
    await _chargesBox.clear();
    deboger("Charges supprimées de StorageService");
  }

  // ==================== RESIDENCES ====================

  /// Récupère toutes les résidences stockées
  List<Map<String, dynamic>> getResidences() {
    _ensureInitialized();
    try {
      final residencesData = _residencesBox.get(_residencesKey);
      if (residencesData == null) return [];

      final List<dynamic> residencesList = residencesData is String
          ? jsonDecode(residencesData)
          : List.from(residencesData);
      return residencesList.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur lors de la récupération des résidences:", e]);
      return [];
    }
  }

  /// Sauvegarde toutes les résidences
  Future<void> saveResidences(List<Map<String, dynamic>> residences) async {
    _ensureInitialized();
    await _residencesBox.put(_residencesKey, residences);
    await _residencesBox.put(_residencesLastSyncKey, DateTime.now().toIso8601String());
    deboger("Résidences sauvegardées: ${residences.length} éléments");
  }

  /// Récupère la date de dernière synchronisation des résidences
  DateTime? getResidencesLastSync() {
    _ensureInitialized();
    final syncDate = _residencesBox.get(_residencesLastSyncKey) as String?;
    return syncDate != null ? DateTime.tryParse(syncDate) : null;
  }

  /// Supprime toutes les résidences
  Future<void> clearResidences() async {
    _ensureInitialized();
    await _residencesBox.clear();
    deboger("Résidences supprimées de StorageService");
  }

  // ==================== APPARTEMENTS ====================

  /// Récupère tous les appartements stockés
  List<Map<String, dynamic>> getAppartements() {
    _ensureInitialized();
    try {
      final appartementsData = _appartementsBox.get(_appartementsKey);
      if (appartementsData == null) return [];

      final List<dynamic> appartementsList = appartementsData is String
          ? jsonDecode(appartementsData)
          : List.from(appartementsData);
      return appartementsList.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur lors de la récupération des appartements:", e]);
      return [];
    }
  }

  /// Sauvegarde tous les appartements
  Future<void> saveAppartements(List<Map<String, dynamic>> appartements) async {
    _ensureInitialized();
    await _appartementsBox.put(_appartementsKey, appartements);
    await _appartementsBox.put(_appartementsLastSyncKey, DateTime.now().toIso8601String());
    deboger("Appartements sauvegardés: ${appartements.length} éléments");
  }

  /// Récupère la date de dernière synchronisation des appartements
  DateTime? getAppartementsLastSync() {
    _ensureInitialized();
    final syncDate = _appartementsBox.get(_appartementsLastSyncKey) as String?;
    return syncDate != null ? DateTime.tryParse(syncDate) : null;
  }

  /// Supprime tous les appartements
  Future<void> clearAppartements() async {
    _ensureInitialized();
    await _appartementsBox.clear();
    deboger("Appartements supprimés de StorageService");
  }

  // ==================== APPARTEMENTS LOCATAIRE (feed découverte) ====================

  /// Récupère le cache du feed locataire (endpoint public `auth/appartement/apparts`).
  ///
  /// Distinct du cache proprio pour éviter les collisions quand un user est
  /// à la fois locataire et propriétaire (vue active).
  List<Map<String, dynamic>> getAppartementsLocataire() {
    _ensureInitialized();
    try {
      final data = _appartementsBox.get(_appartementsLocataireKey);
      if (data == null) return [];
      final List<dynamic> list = data is String
          ? jsonDecode(data)
          : List.from(data);
      return list.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur getAppartementsLocataire:", e]);
      return [];
    }
  }

  /// Sauvegarde le cache du feed locataire.
  Future<void> saveAppartementsLocataire(
    List<Map<String, dynamic>> appartements,
  ) async {
    _ensureInitialized();
    await _appartementsBox.put(_appartementsLocataireKey, appartements);
    await _appartementsBox.put(
      _appartementsLocataireLastSyncKey,
      DateTime.now().toIso8601String(),
    );
    deboger("Appartements locataire sauvegardés: ${appartements.length}");
  }

  /// Date de dernière synchronisation du cache feed locataire.
  DateTime? getAppartementsLocataireLastSync() {
    _ensureInitialized();
    final syncDate =
        _appartementsBox.get(_appartementsLocataireLastSyncKey) as String?;
    return syncDate != null ? DateTime.tryParse(syncDate) : null;
  }

  /// Vide le cache feed locataire.
  Future<void> clearAppartementsLocataire() async {
    _ensureInitialized();
    await _appartementsBox.delete(_appartementsLocataireKey);
    await _appartementsBox.delete(_appartementsLocataireLastSyncKey);
    deboger("Cache appartements locataire vidé");
  }

  // ==================== PROPRIETAIRES (cache locataire) ====================

  /// Récupère un propriétaire depuis le cache par appartementId
  Map<String, dynamic>? getProprietaire(int appartementId) {
    _ensureInitialized();
    try {
      final proprietairesData = _proprietairesBox.get(_proprietairesKey);
      if (proprietairesData == null) return null;

      final Map<String, dynamic> proprietairesMap = proprietairesData is String
          ? _convertMap(jsonDecode(proprietairesData) as Map)
          : _convertMap(proprietairesData as Map);

      final key = appartementId.toString();
      if (proprietairesMap.containsKey(key)) {
        return _convertMap(proprietairesMap[key] as Map);
      }
      return null;
    } catch (e) {
      deboger(["Erreur lors de la récupération du propriétaire:", e]);
      return null;
    }
  }

  /// Sauvegarde un propriétaire dans le cache par appartementId
  Future<void> saveProprietaire(int appartementId, Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final proprietairesData = _proprietairesBox.get(_proprietairesKey);
      Map<String, dynamic> proprietairesMap = {};

      if (proprietairesData != null) {
        proprietairesMap = proprietairesData is String
            ? _convertMap(jsonDecode(proprietairesData) as Map)
            : _convertMap(proprietairesData as Map);
      }

      proprietairesMap[appartementId.toString()] = data;
      await _proprietairesBox.put(_proprietairesKey, proprietairesMap);
      deboger("Propriétaire sauvegardé pour appartement $appartementId");
    } catch (e) {
      deboger(["Erreur lors de la sauvegarde du propriétaire:", e]);
    }
  }

  /// Supprime tous les propriétaires du cache
  Future<void> clearProprietaires() async {
    _ensureInitialized();
    await _proprietairesBox.clear();
    deboger("Propriétaires supprimés de StorageService");
  }

  // ==================== RESERVATIONS ====================

  /// Récupère toutes les réservations stockées
  List<Map<String, dynamic>> getReservations() {
    _ensureInitialized();
    try {
      final reservationsData = _reservationsBox.get(_reservationsKey);
      if (reservationsData == null) return [];

      final List<dynamic> reservationsList = reservationsData is String
          ? jsonDecode(reservationsData)
          : List.from(reservationsData);
      return reservationsList.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur lors de la récupération des réservations:", e]);
      return [];
    }
  }

  /// Sauvegarde toutes les réservations
  Future<void> saveReservations(List<Map<String, dynamic>> reservations) async {
    _ensureInitialized();
    await _reservationsBox.put(_reservationsKey, reservations);
    await _reservationsBox.put(_reservationsLastSyncKey, DateTime.now().toIso8601String());
    deboger("Réservations sauvegardées: ${reservations.length} éléments");
  }

  /// Récupère la date de dernière synchronisation des réservations
  DateTime? getReservationsLastSync() {
    _ensureInitialized();
    final syncDate = _reservationsBox.get(_reservationsLastSyncKey) as String?;
    return syncDate != null ? DateTime.tryParse(syncDate) : null;
  }

  /// Supprime toutes les réservations
  Future<void> clearReservations() async {
    _ensureInitialized();
    await _reservationsBox.clear();
    deboger("Réservations supprimées de StorageService");
  }

  // ==================== RESERVATIONS PROPRIÉTAIRE ====================

  /// Récupère les réservations du propriétaire (cache séparé du locataire)
  List<Map<String, dynamic>> getProprioReservations() {
    _ensureInitialized();
    try {
      final data = _reservationsBox.get(_proprioReservationsKey);
      if (data == null) return [];

      final List<dynamic> list = data is String
          ? jsonDecode(data)
          : List.from(data);
      return list.map((e) => _convertMap(e as Map)).toList();
    } catch (e) {
      deboger(["Erreur lors de la récupération des réservations proprio:", e]);
      return [];
    }
  }

  /// Sauvegarde les réservations du propriétaire
  Future<void> saveProprioReservations(List<Map<String, dynamic>> reservations) async {
    _ensureInitialized();
    await _reservationsBox.put(_proprioReservationsKey, reservations);
    await _reservationsBox.put(_proprioReservationsLastSyncKey, DateTime.now().toIso8601String());
    deboger("Réservations proprio sauvegardées: ${reservations.length} éléments");
  }

  /// Récupère la date de dernière synchronisation des réservations proprio
  DateTime? getProprioReservationsLastSync() {
    _ensureInitialized();
    final syncDate = _reservationsBox.get(_proprioReservationsLastSyncKey) as String?;
    return syncDate != null ? DateTime.tryParse(syncDate) : null;
  }

  /// Supprime les réservations du propriétaire
  Future<void> clearProprioReservations() async {
    _ensureInitialized();
    await _reservationsBox.delete(_proprioReservationsKey);
    await _reservationsBox.delete(_proprioReservationsLastSyncKey);
    deboger("Réservations proprio supprimées de StorageService");
  }

  // ==================== CLEAR ====================

  /// Supprime toutes les données (token + user + cache proprio)
  ///
  /// Utilisé lors du logout complet
  Future<void> clear() async {
    _ensureInitialized();
    await Future.wait([
      SecureStorageService.instance.deleteToken(),
      _authBox.clear(),
      _userBox.clear(),
      _chargesBox.clear(),
      _residencesBox.clear(),
      _appartementsBox.clear(),
      _proprietairesBox.clear(),
      _reservationsBox.clear(),
      _appartementDraftBox.clear(),
    ]);
    deboger("StorageService - Toutes les données supprimées");
  }

  /// Supprime uniquement les données du propriétaire (cache)
  ///
  /// Utilisé lors du changement de compte ou rafraîchissement forcé
  Future<void> clearProprioData() async {
    _ensureInitialized();
    await Future.wait([
      _chargesBox.clear(),
      _residencesBox.clear(),
      _appartementsBox.clear(),
      _appartementDraftBox.clear(),
      clearProprioReservations(),
    ]);
    deboger("StorageService - Données proprio supprimées");
  }

  // ==================== APPARTEMENT DRAFT (wizard) ====================

  /// Box brute du brouillon d'appartement (wizard d'ajout/édition).
  ///
  /// Exposée pour [AppartementDraftStorage] qui gère sa sérialisation JSON.
  Box get draftBox {
    _ensureInitialized();
    return _appartementDraftBox;
  }

  /// Supprime le brouillon courant.
  Future<void> clearAppartementDraft() async {
    _ensureInitialized();
    await _appartementDraftBox.clear();
    deboger("Brouillon d'appartement supprimé de StorageService");
  }

  // ==================== APP SETTINGS (flags applicatifs) ====================

  /// Récupère un réglage applicatif (ex : flag de migration).
  ///
  /// Retourne `null` si la clé n'existe pas.
  T? getAppSetting<T>(String key) {
    _ensureInitialized();
    final value = _appSettingsBox.get(key);
    if (value is T) return value;
    return null;
  }

  /// Pose un réglage applicatif (ex : flag de migration `done`).
  Future<void> setAppSetting<T>(String key, T value) async {
    _ensureInitialized();
    await _appSettingsBox.put(key, value);
  }

  /// Supprime un réglage applicatif.
  Future<void> deleteAppSetting(String key) async {
    _ensureInitialized();
    await _appSettingsBox.delete(key);
  }

  // ==================== ACTIVE VIEW (V8.5) ====================

  /// Clé Hive pour la vue active de l'utilisateur (différente de `user.type`).
  ///
  /// Permet à un proprio/démarcheur de basculer en mode Locataire pour
  /// séjourner ailleurs sans changer son type de compte.
  static const String _activeViewKey = 'active_view';

  /// Récupère la vue active persistée.
  ///
  /// Retourne `null` si jamais définie (l'utilisateur ouvre alors l'interface
  /// de son `user.type` par défaut).
  String? getActiveView() => getAppSetting<String>(_activeViewKey);

  /// Persiste la vue active. Passer `null` pour réinitialiser (au logout).
  Future<void> saveActiveView(String? viewId) async {
    if (viewId == null) {
      await deleteAppSetting(_activeViewKey);
    } else {
      await setAppSetting<String>(_activeViewKey, viewId);
    }
  }

  // ==================== UTILITY ====================

  /// Convertit récursivement les Map Hive (_Map<dynamic, dynamic>)
  /// en Map<String, dynamic> pour éviter les erreurs de type casting
  static Map<String, dynamic> _convertMap(Map map) {
    return map.map((key, value) => MapEntry(
      key.toString(),
      _convertValue(value),
    ));
  }

  /// Convertit récursivement une valeur (Map, List, ou valeur primitive)
  static dynamic _convertValue(dynamic value) {
    if (value is Map) {
      return _convertMap(value);
    } else if (value is List) {
      return value.map((e) => _convertValue(e)).toList();
    }
    return value;
  }

  /// Affiche le contenu actuel du storage (pour debug)
  void debugPrint() {
    _ensureInitialized();
    deboger([
      "=== StorageService Debug ===",
      "Token: ${hasToken() ? 'présent' : 'absent'}",
      "User: ${hasUser() ? 'présent' : 'absent'}",
      "=========================="
    ]);
  }
}
