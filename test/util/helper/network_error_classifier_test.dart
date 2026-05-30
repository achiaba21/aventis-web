import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/helper/network_error_classifier.dart';

void main() {
  final reqOptions = RequestOptions(path: '/test');

  group('NetworkErrorClassifier.isNetworkError', () {
    test('SocketException → réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          const SocketException('no route to host'),
        ),
        isTrue,
      );
    });

    test('DioException connectionError → réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.connectionError,
          ),
        ),
        isTrue,
      );
    });

    test('DioException connectionTimeout → réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isTrue,
      );
    });

    test('DioException receiveTimeout/sendTimeout → réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.receiveTimeout,
          ),
        ),
        isTrue,
      );
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.sendTimeout,
          ),
        ),
        isTrue,
      );
    });

    test('DioException unknown emballant une SocketException → réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.unknown,
            error: const SocketException('connection failed'),
          ),
        ),
        isTrue,
      );
    });

    test('DioException badResponse 404 → métier (pas réseau)', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: reqOptions, statusCode: 404),
          ),
        ),
        isFalse,
      );
    });

    test('DioException badResponse 400 → métier (pas réseau)', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: reqOptions, statusCode: 400),
          ),
        ),
        isFalse,
      );
    });

    test('DioException cancel → pas réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(
          DioException(
            requestOptions: reqOptions,
            type: DioExceptionType.cancel,
          ),
        ),
        isFalse,
      );
    });

    test('CustomException métier → pas réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(CustomException('Donnée invalide')),
        isFalse,
      );
    });

    test('Exception générique → pas réseau', () {
      expect(
        NetworkErrorClassifier.isNetworkError(Exception('boom')),
        isFalse,
      );
    });
  });
}
