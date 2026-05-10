import 'package:dio/dio.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/error_handler.dart';
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
    final body = option.data;
    //option.responseType = ResponseType.plain;

    // Injecter le token pour les routes protégées (sans auth/)
    if (!uri.path.startsWith('/api/auth/')) {
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        option.headers['Authorization'] = 'Bearer $_currentToken';
        deboger("Token ajouté pour $end");
      } else {
        deboger("Pas de token disponible pour $end");
      }
    }

    deboger("Url : $end \nheaders: ${option.headers}");
    prettyPrint(body,label: "corp");
    handler.next(option);
  }

  void _onResponse(Response<dynamic> resp, ResponseInterceptorHandler handler) {
    final end = resp.realUri.path;
    final body = resp.data;
    final code = resp.statusCode;
    deboger("Url : $end\nheaders: ${resp.headers}\nstatu : $code");
    prettyPrint(body);
    return handler.next(resp);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) async {

    deboger(["error", error.requestOptions.headers,error.message]);

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
