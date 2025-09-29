import 'package:dio/dio.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/error_handler.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/response/response_mapper.dart';

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

  late Dio _dio;

  DioRequest._internal() {
    final options = BaseOptions(
      baseUrl: "$domain/",
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 3),
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

    // Injecter le token pour les routes protégées (sans auth/)
    if (!uri.path.startsWith('/auth/')) {
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        option.headers['Authorization'] = 'Bearer $_currentToken';
        deboger("Token ajouté pour $end");
      } else {
        deboger("Pas de token disponible pour $end");
      }
    }

    deboger("Url : $end \nheaders: ${option.headers} \ncorp: $body");
    handler.next(option);
  }

  void _onResponse(Response<dynamic> resp, ResponseInterceptorHandler handler) {
    final end = resp.realUri.path;
    final body = resp.data;
    final code = resp.statusCode;
    deboger("Url : $end\nheaders: ${resp.headers} \ncorp: $body\nstatu : $code");
    return handler.next(resp);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {

    deboger(["error", error.requestOptions.headers,error.message]);
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
