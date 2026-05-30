import 'dart:io';
import 'package:dio/dio.dart';

/// Classifie une erreur comme **réseau** (à rejouer) ou **métier** (à afficher).
///
/// Une erreur réseau est une coupure de connexion / timeout : elle est
/// transitoire et doit être mise en file pour rejeu automatique au retour de
/// la connexion. Une erreur métier (réponse HTTP 4xx/5xx, exception applicative)
/// n'est PAS rejouée — elle reflète un problème côté données/serveur que rejouer
/// ne résoudra pas.
///
/// Helper pur : aucune dépendance Flutter, entièrement testable.
class NetworkErrorClassifier {
  NetworkErrorClassifier._();

  /// `true` si l'erreur est due au réseau (connexion/timeout), `false` sinon.
  static bool isNetworkError(Object error) {
    if (error is SocketException) return true;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return true;
        case DioExceptionType.badResponse:
          // Réponse HTTP reçue (4xx/5xx) → erreur métier, pas réseau.
          return false;
        case DioExceptionType.cancel:
          return false;
        case DioExceptionType.badCertificate:
          return false;
        case DioExceptionType.unknown:
          // Souvent une SocketException emballée dans error.error.
          return error.error is SocketException;
      }
    }

    return false;
  }
}
