import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:asfar/util/function.dart';

/// Accès unique au stockage sécurisé de l'OS (Keychain iOS / Keystore Android)
///
/// Détient les deux seuls secrets de l'application :
/// - le jeton de session (JWT), avec un cache mémoire qui permet une lecture
///   synchrone par [StorageService] et [AuthManager] ;
/// - la clé AES qui chiffre les boxes Hive.
///
/// Suit les principes :
/// - Single Responsibility : gère uniquement les secrets
/// - Singleton : une seule instance dans toute l'application
class SecureStorageService {
  static SecureStorageService? _instance;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _hiveKeyKey = 'hive_encryption_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _cachedToken;
  String? _cachedRefreshToken;
  bool _isInitialized = false;

  /// Singleton instance
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._internal();
    return _instance!;
  }

  SecureStorageService._internal();

  /// Pré-charge le jeton en mémoire
  ///
  /// Doit être appelé au démarrage de l'application (dans main.dart)
  /// AVANT StorageService.instance.init()
  Future<void> init() async {
    if (_isInitialized) {
      deboger("SecureStorageService déjà initialisé");
      return;
    }
    try {
      _cachedToken = await _storage.read(key: _tokenKey);
      _cachedRefreshToken = await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      // Stockage sécurisé illisible (restauration de backup, clé OS perdue) :
      // on repart sans session, l'utilisateur se reconnecte. Jamais de crash.
      deboger(["SecureStorageService illisible, session réinitialisée:", e]);
      _cachedToken = null;
      _cachedRefreshToken = null;
    }
    _isInitialized = true;
    deboger("SecureStorageService initialisé (token: "
        "${_cachedToken != null ? 'présent' : 'absent'})");
  }

  /// Jeton de session en cache mémoire (lecture synchrone)
  String? get cachedToken => _cachedToken;

  /// Sauvegarde le jeton de session (Keychain/Keystore + cache mémoire)
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Supprime le jeton de session (Keychain/Keystore + cache mémoire)
  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Refresh token opaque en cache mémoire (lecture synchrone)
  String? get cachedRefreshToken => _cachedRefreshToken;

  /// Sauvegarde le refresh token (Keychain/Keystore + cache mémoire).
  /// Appelé au login ET à chaque refresh (rotation backend → nouveau token).
  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Supprime le refresh token (Keychain/Keystore + cache mémoire)
  Future<void> deleteRefreshToken() async {
    _cachedRefreshToken = null;
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Retourne la clé AES (32 octets) qui chiffre les boxes Hive
  ///
  /// Générée une seule fois au premier lancement via [Hive.generateSecureKey]
  /// puis conservée dans le stockage sécurisé. Si elle devient illisible,
  /// une nouvelle clé est générée : les boxes existantes seront illisibles
  /// et purgées par StorageService (reconnexion forcée, comportement voulu).
  Future<List<int>> getOrCreateHiveKey() async {
    try {
      final stored = await _storage.read(key: _hiveKeyKey);
      if (stored != null) {
        return base64Decode(stored);
      }
    } catch (e) {
      deboger(["Clé Hive illisible, régénération:", e]);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: _hiveKeyKey, value: base64Encode(key));
    return key;
  }
}
