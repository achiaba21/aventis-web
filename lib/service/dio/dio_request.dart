import 'package:dio/dio.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/connectivity/connectivity_service.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/helper/network_error_classifier.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/phone_util.dart';
import 'package:asfar/main.dart';
import 'package:asfar/screen/splash_screen.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';

class DioRequest {
  static DioRequest? _instance;
  String? _currentToken;

  /// Marqueur posé sur une requête déjà prise en charge par le retry réseau,
  /// pour éviter qu'elle ne ré-entre dans la boucle de rejeu à chaque échec.
  static const String _netRetryFlag = '__net_retry__';

  static DioRequest get instance {
    _instance = _instance ?? DioRequest._internal();
    return _instance!;
  }

  void setToken(String? token) {
    _currentToken = token;
    deboger("Token mis à jour: ${token != null ? 'présent' : 'absent'}");
  }

  void clearToken() {
    _currentToken = null;
    deboger("Token supprimé");
  }

  bool get hasToken => _currentToken != null && _currentToken!.isNotEmpty;

  late Dio _dio;

  DioRequest._internal() {
    final options = BaseOptions(
      baseUrl: "$domain/",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
    );
    _dio = Dio(options);
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onSendProgress,
      onSendProgress: onSendProgress,
    );
  }

  /// Envoie une requête POST avec FormData (multipart/form-data)
  ///
  /// Utilisé pour envoyer des fichiers (images, documents) avec des données JSON
  /// Le Content-Type sera automatiquement défini à multipart/form-data par Dio
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'json': jsonEncode({...}),
  ///   'images': [
  ///     await MultipartFile.fromFile('path/to/image.jpg', filename: 'image.jpg')
  ///   ]
  /// });
  /// await DioRequest.instance.postFormData('endpoint', formData: formData);
  /// ```
  Future<Response<T>> postFormData<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Envoie une requête PUT avec FormData (multipart/form-data)
  ///
  /// Utilisé pour mettre à jour des ressources avec fichiers (images, documents) et données JSON
  /// Le Content-Type sera automatiquement défini à multipart/form-data par Dio
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'json': jsonEncode({...}),
  ///   'images': [
  ///     await MultipartFile.fromFile('path/to/image.jpg', filename: 'image.jpg')
  ///   ]
  /// });
  /// await DioRequest.instance.putFormData('endpoint/123', formData: formData);
  /// ```
  Future<Response<T>> putFormData<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.put(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return _dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onSendProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onSendProgress,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onSendProgress,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  void _onRequest(RequestOptions option, RequestInterceptorHandler handler) {
    final uri = option.uri;
    final end = uri.toString();

    // Injecter le token pour les routes protégées (sans auth/)
    if (!uri.path.startsWith('/api/auth/')) {
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        option.headers['Authorization'] = 'Bearer $_currentToken';
        deboger("Token ajouté pour $end");
      } else {
        deboger("Pas de token disponible pour $end");
      }
    }

    // SEC-04 : jamais de headers ni de body dans les logs
    // (le header Authorization contient le jeton, les bodies des données perso)
    deboger("→ ${option.method} $end");
    handler.next(option);
  }

  void _onResponse(Response<dynamic> resp, ResponseInterceptorHandler handler) {
    final end = resp.realUri.path;
    final code = resp.statusCode;
    // SEC-04 : jamais de headers ni de body dans les logs
    deboger("← $code $end");
    return handler.next(resp);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) async {
    // SEC-04 : pas de headers (jeton) dans les logs d'erreur
    deboger(["error", error.requestOptions.path, error.message]);

    // Gérer les erreurs 401 (token invalide ou expiré)
    if (error.response?.statusCode == 401) {
      deboger("Token invalide ou expiré - Affichage de l'écran de connexion");

      // Récupérer le numéro de téléphone de l'utilisateur avant la déconnexion
      final phoneNumber = await UserBloc.getCurrentUserPhone();
      final phoneWithoutCode = phoneNumber != null
          ? PhoneUtil.removeCountryCode(phoneNumber)
          : null;

      // Déconnexion centralisée via AuthManager
      // Cela nettoie: token (StorageService + DioRequest) + user (StorageService) + AppData
      await AuthManager.instance.logout();

      // TODO REBUILD: rediriger vers le nouveau LoginScreen quand il sera
      // reconstruit. Pour l'instant, retombe sur le SplashScreen placeholder.
      final context = navigatorKey.currentContext;
      if (context != null) {
        await pushScreen(context, const SplashScreen());
      }

      // Propager l'erreur
      return handler.next(error);
    }

    // ============ RETRY RÉSEAU (lectures GET) ============
    // Si la requête échoue pour cause RÉSEAU (pas d'internet / timeout), on la
    // suspend et on la rejoue automatiquement dès que la connexion serveur
    // revient (source de vérité : socket via ConnectivityService). Couvre TOUS
    // les chargements de données de l'app sans modifier le moindre BLoC.
    // Lectures uniquement : on ne rejoue pas les écritures (POST/PUT/DELETE).
    final opts = error.requestOptions;
    final isGet = opts.method.toUpperCase() == 'GET';
    final alreadyRetrying = opts.extra[_netRetryFlag] == true;
    if (isGet &&
        !alreadyRetrying &&
        NetworkErrorClassifier.isNetworkError(error)) {
      opts.extra[_netRetryFlag] = true;
      _retryWhenOnline(opts, handler);
      return;
    }

    // Logger l'erreur avec plus de détails
    ErrorHandler.logError("DIO REQUEST", error);

    // Extraire le message d'erreur propre
    final cleanMessage = ErrorHandler.extractErrorMessage(error);

    // Créer une nouvelle DioException avec le message propre
    final modifiedError = DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: cleanMessage,
      message: cleanMessage,
    );

    return handler.next(modifiedError);
  }

  /// Suspend une requête GET échouée pour cause réseau et la rejoue dès que la
  /// connexion serveur revient. Le `Future` d'origine du BLoC ne se résout
  /// qu'avec la réponse finale → l'écran se met à jour tout seul, sans
  /// redémarrage et sans code spécifique par écran.
  Future<void> _retryWhenOnline(
    RequestOptions opts,
    ErrorInterceptorHandler handler,
  ) async {
    final conn = ConnectivityService.instance;
    int onlineButFailing = 0;
    while (true) {
      if (!conn.isOnline) {
        // Attend la transition online (sans timeout → survit aux coupures
        // longues, exactement le besoin : « quand la co revient, on rejoue »).
        await conn.waitForOnline();
      } else {
        // Connecté mais la requête échoue quand même (serveur momentanément
        // injoignable) : backoff borné pour éviter une boucle serrée.
        if (onlineButFailing >= 3) {
          return handler.next(
            DioException(
              requestOptions: opts,
              type: DioExceptionType.connectionError,
              error: 'Erreur de connexion',
              message: 'Erreur de connexion',
            ),
          );
        }
        onlineButFailing++;
        await Future.delayed(Duration(seconds: 2 * onlineButFailing));
      }

      try {
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } on DioException catch (e) {
        if (NetworkErrorClassifier.isNetworkError(e)) {
          continue; // de nouveau offline → ré-attendre le retour
        }
        return handler.next(e); // erreur métier → propager normalement
      } catch (e) {
        return handler.next(DioException(requestOptions: opts, error: e));
      }
    }
  }

  // === MÉTHODES GÉNÉRIQUES AVEC MAPPING AUTOMATIQUE ===

  /// Registre des constructeurs JSON pour chaque type
  static final Map<Type, Map<String, Function>> _jsonConstructorRegistry = {};

  /// Enregistre les constructeurs JSON pour un type
  static void registerJsonConstructors<T>(
    T Function(Map<String, dynamic>) fromJson,
    [T Function(Map<String, dynamic>)? fromJsonAll]
  ) {
    _jsonConstructorRegistry[T] = {
      'fromJson': fromJson,
      if (fromJsonAll != null) 'fromJsonAll': fromJsonAll,
    };
  }

  /// Récupère les constructeurs enregistrés pour le type T
  Map<String, Function?> _getJsonConstructors<T>() {
    final constructors = _jsonConstructorRegistry[T];
    if (constructors == null) {
      throw CustomException(
        'Le type $T n\'est pas enregistré. Utilisez DioRequest.registerJsonConstructors<$T>() '
        'ou utilisez les méthodes *Mapped avec paramètres explicites.'
      );
    }

    return {
      'fromJson': constructors['fromJson'],
      'fromJsonAll': constructors['fromJsonAll'],
    };
  }

  /// GET générique avec détection automatique de fromJson/fromJsonAll
  Future<List<T>> getMapped<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );

    final constructors = _getJsonConstructors<T>();

    return ResponseMapper.mapResponseAuto<T>(
      response: response,
      fromJsonConstructor: constructors['fromJson']! as T Function(Map<String, dynamic>),
      fromJsonAllConstructor: constructors['fromJsonAll'] as T Function(Map<String, dynamic>)?,
    );
  }

  /// POST générique avec détection automatique de fromJson/fromJsonAll
  Future<List<T>> postMapped<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    final constructors = _getJsonConstructors<T>();

    return ResponseMapper.mapResponseAuto<T>(
      response: response,
      fromJsonConstructor: constructors['fromJson']! as T Function(Map<String, dynamic>),
      fromJsonAllConstructor: constructors['fromJsonAll'] as T Function(Map<String, dynamic>)?,
    );
  }

  /// PUT générique avec détection automatique de fromJson/fromJsonAll
  Future<List<T>> putMapped<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    final constructors = _getJsonConstructors<T>();

    return ResponseMapper.mapResponseAuto<T>(
      response: response,
      fromJsonConstructor: constructors['fromJson']! as T Function(Map<String, dynamic>),
      fromJsonAllConstructor: constructors['fromJsonAll'] as T Function(Map<String, dynamic>)?,
    );
  }

  /// PATCH générique avec détection automatique de fromJson/fromJsonAll
  Future<List<T>> patchMapped<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    final constructors = _getJsonConstructors<T>();

    return ResponseMapper.mapResponseAuto<T>(
      response: response,
      fromJsonConstructor: constructors['fromJson']! as T Function(Map<String, dynamic>),
      fromJsonAllConstructor: constructors['fromJsonAll'] as T Function(Map<String, dynamic>)?,
    );
  }

  /// DELETE générique avec détection automatique de fromJson/fromJsonAll
  Future<List<T>> deleteMapped<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );

    final constructors = _getJsonConstructors<T>();

    return ResponseMapper.mapResponseAuto<T>(
      response: response,
      fromJsonConstructor: constructors['fromJson']! as T Function(Map<String, dynamic>),
      fromJsonAllConstructor: constructors['fromJsonAll'] as T Function(Map<String, dynamic>)?,
    );
  }
}
