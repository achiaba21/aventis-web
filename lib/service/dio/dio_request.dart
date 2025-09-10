import 'package:dio/dio.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class DioRequest {
  static DioRequest? _instance;

  static DioRequest get instance {
    _instance = _instance ?? DioRequest._internal();
    return _instance!;
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
    deboger("Url : $end \ncorp: $body");
    return handler.next(option);
  }

  void _onResponse(Response<dynamic> resp, ResponseInterceptorHandler handler) {
    final end = resp.realUri.path;
    final body = resp.data;
    final code = resp.statusCode;
    deboger("Url : $end\ncorp: $body\nstatu : $code");
    return handler.next(resp);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) {
    return handler.next(error);
  }
}
