import 'package:dio/dio.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class ErrorHandler {
  /// Messages d'erreur par défaut selon le code de statut
  static const Map<int, String> _defaultMessages = {
    400: "Données invalides",
    401: "Accès non autorisé",
    403: "Accès interdit",
    404: "Ressource non trouvée",
    409: "Conflit de données",
    422: "Données incorrectes",
    500: "Erreur serveur",
    502: "Service indisponible",
    503: "Service temporairement indisponible",
  };

  /// Extrait un message d'erreur propre depuis une DioException
  static String extractErrorMessage(DioException error) {
    try {
      deboger(["extracting error from:", error.response?.data]);

      // Essayer d'extraire le message depuis response.data
      final responseData = error.response?.data;
      deboger(["extracted error data:", responseData, "error:", error.error]);

      if (responseData != null) {
        // Si c'est un Map, essayer les champs communs
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] ??
                         responseData['error'] ??
                         responseData['detail'] ??
                         responseData['msg'];

          if (message != null && message.toString().isNotEmpty) {
            return message.toString();
          }
        }

        // Si c'est une String directe
        if (responseData is String && responseData.isNotEmpty) {
          return responseData;
        }
      }

      // Si pas de response.data utile, essayer error (erreurs Dio : connexion, timeout, etc.)
      if (error.error != null) {
        final errorString = error.error.toString();
        if (errorString.isNotEmpty && errorString != "null") {
          return errorString;
        }
      }

      // Fallback sur le message par code de statut
      final statusCode = error.response?.statusCode;
      if (statusCode != null && _defaultMessages.containsKey(statusCode)) {
        return _defaultMessages[statusCode]!;
      }

      // Fallback sur le message de l'exception Dio
      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }

      return "Erreur de connexion";

    } catch (e) {
      deboger(["error extracting message:", e]);
      return "Erreur de connexion";
    }
  }

  /// Extrait un message d'erreur depuis une exception générique
  static String extractGenericErrorMessage(dynamic error) {
    if (error is DioException) {
      return extractErrorMessage(error);
    } else if (error is CustomException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return error?.toString() ?? "Une erreur est survenue";
    }
  }

  /// Log une erreur avec plus de détails
  static void logError(String context, dynamic error) {
    if (error is DioException) {
      deboger([
        "=== ERREUR $context ===",
        "URL:", error.requestOptions.uri.toString(),
        "Méthode:", error.requestOptions.method,
        "Code:", error.response?.statusCode,
        "Response data:", error.response?.data,
        "Message:", error.message,
        "========================"
      ]);
    } else {
      deboger(["=== ERREUR $context ===", error, "========================"]);
    }
  }
}