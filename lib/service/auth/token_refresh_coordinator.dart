import 'package:dio/dio.dart';
import 'package:asfar/dto/token.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/storage/secure_storage_service.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Coordonne le rafraîchissement de l'access token via `POST auth/refresh`.
///
/// **Single-flight** : un seul refresh peut être en vol à la fois ; tous les
/// appelants concurrents (intercepteur Dio 401, WebSocket, démarrage) attendent
/// le même `Future`. Indispensable car le backend **fait tourner** le refresh
/// token (rotation) : deux refresh parallèles avec le même token → le second
/// prend un 401.
///
/// En cas de succès, l'access + le **nouveau** refresh token (rotation) sont
/// persistés et `DioRequest` est synchronisé. Retourne `false` si aucun refresh
/// token n'est stocké ou si le backend refuse (401 → session morte).
class TokenRefreshCoordinator {
  TokenRefreshCoordinator._();

  static final TokenRefreshCoordinator instance = TokenRefreshCoordinator._();

  /// Endpoint public (préfixe `auth/`, sans Bearer requis).
  static const String _refreshUrl = 'auth/refresh';

  Future<bool>? _inFlight;

  /// Lance (ou rejoint) un refresh. Garantit qu'un seul appel réseau a lieu
  /// même si plusieurs 401 surviennent en même temps.
  Future<bool> refresh() {
    return _inFlight ??= _doRefresh().whenComplete(() => _inFlight = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = SecureStorageService.instance.cachedRefreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      deboger('[Refresh] aucun refresh token stocké → impossible');
      return false;
    }

    try {
      final response = await DioRequest.instance.post(
        _refreshUrl,
        data: {'refreshToken': refreshToken},
        // L'intercepteur 401 doit laisser passer CET appel sans reboucler.
        options: Options(extra: {DioRequest.refreshCallExtra: true}),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        deboger('[Refresh] réponse inattendue (pas un objet JSON)');
        return false;
      }

      final token = Token.fromJson(data);
      if (token.token == null ||
          token.token!.isEmpty ||
          token.refreshToken == null ||
          token.refreshToken!.isEmpty) {
        deboger('[Refresh] réponse sans token/refreshToken');
        return false;
      }

      // Rotation : on remplace l'access ET le refresh stockés.
      await StorageService.instance.saveToken(token.token!);
      await SecureStorageService.instance.saveRefreshToken(token.refreshToken!);
      DioRequest.instance.setToken(token.token!);
      if (token.user != null) {
        await StorageService.instance.saveUser(token.user!);
      }

      deboger('[Refresh] OK — access + refresh renouvelés (rotation)');
      return true;
    } catch (e) {
      // 401 (refresh invalide/expiré/révoqué) ou erreur réseau → échec.
      deboger(['[Refresh] échec', e]);
      return false;
    }
  }
}
