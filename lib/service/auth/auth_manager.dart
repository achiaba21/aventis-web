import 'dart:async';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/color/color_manager.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Gestionnaire centralisé de l'authentification
/// Singleton qui coordonne la gestion du token, de l'utilisateur et des données de l'app
class AuthManager {
  static AuthManager? _instance;

  // Stream pour notifier les changements d'état d'authentification
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  static AuthManager get instance {
    _instance ??= AuthManager._internal();
    return _instance!;
  }

  AuthManager._internal();

  /// Vérifie si l'utilisateur est authentifié (a un token valide)
  Future<bool> get isAuthenticated async {
    final token = StorageService.instance.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Vérifie le token de manière synchrone (pour le router)
  bool get isAuthenticatedSync {
    // Cette méthode sera utilisée par le router guard
    // Note: Pour une vraie vérification async, utiliser isAuthenticated
    final dioRequest = DioRequest.instance;
    return dioRequest.hasToken;
  }

  /// Login: enregistre le token et l'utilisateur
  Future<void> login(String token, User user) async {
    deboger("AuthManager: Login user ${user.fullName}");

    // Sauvegarder le token dans StorageService
    await StorageService.instance.saveToken(token);

    // Synchroniser le token avec DioRequest (CRITIQUE!)
    DioRequest.instance.setToken(token);

    // Sauvegarder l'utilisateur dans StorageService
    await StorageService.instance.saveUser(user);

    // Notifier le changement d'état
    _authStateController.add(true);

    deboger("AuthManager: Login completed");
  }

  /// Logout: nettoie TOUT (token + données utilisateur)
  Future<void> logout() async {
    deboger("AuthManager: Starting logout");

    // 1. Nettoyer toutes les données (token + user) dans StorageService
    await StorageService.instance.clear();

    // 2. Nettoyer le token dans DioRequest
    DioRequest.instance.clearToken();

    // 3. Nettoyer les couleurs des appartements en cache
    ColorManager.instance.clearColors();

    // 4. Notifier le changement d'état (les BLoCs réagiront à ce changement)
    _authStateController.add(false);

    deboger("AuthManager: Logout completed");
  }

  /// Vérifie si le token est encore valide
  Future<bool> validateToken() async {
    final token = StorageService.instance.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Vous pouvez ajouter ici une validation plus sophistiquée
    // Par exemple: vérifier la date d'expiration du JWT

    return true;
  }

  /// Nettoie les ressources
  void dispose() {
    _authStateController.close();
  }
}
