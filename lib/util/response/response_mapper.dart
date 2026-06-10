import 'package:dio/dio.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/http_function.dart';

/// Interface pour les modèles qui supportent le mapping JSON
abstract class JsonMappable {
  /// Sérialisation vers JSON - doit être implémentée par toutes les classes
  Map<String, dynamic> toJson();
}

/// Interface pour les constructeurs JSON statiques
abstract class JsonConstructors<T> {
  static T fromJson<T>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }

  static T fromJsonAll<T>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJsonAll must be implemented by subclasses with inheritance');
  }
}

/// Classe générique pour mapper les réponses API vers des modèles
class ResponseMapper {

  /// Map automatiquement une réponse API vers un modèle T
  ///
  /// Le type T doit avoir une méthode statique fromJson ou fromJsonAll
  /// Cette méthode utilise la réflexion Dart pour déterminer automatiquement
  /// la méthode de mapping appropriée
  ///
  /// Retourne:
  /// - Liste&lt;T&gt; si la réponse contient un array
  /// - Liste&lt;T&gt; avec un seul élément si la réponse contient un objet unique
  static List<T> mapResponseAuto<T>({
    required Response response,
    required T Function(Map<String, dynamic>) fromJsonConstructor,
    T Function(Map<String, dynamic>)? fromJsonAllConstructor,
  }) {
    // Vérifier les erreurs HTTP
    if (hasError(response)) {
      throw CustomException(response.statusMessage ?? "Erreur de réponse");
    }

    // Vérifier si la réponse contient des données
    if (response.data == null) {
      throw CustomException("Aucune donnée reçue");
    }

    try {
      final data = response.data;
      final mapFunction = fromJsonAllConstructor ?? fromJsonConstructor;

      // Mapping résilient : un item qui échoue (champ malformé, type
      // inattendu) est ignoré + loggué plutôt que de faire échouer toute la
      // liste. Évite qu'une seule annonce corrompue masque toutes les autres.
      if (data is List) {
        final result = <T>[];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is! Map<String, dynamic>) {
            deboger([
              '[ResponseMapper] item #$i ignoré : format invalide '
                  '(${item.runtimeType})'
            ]);
            continue;
          }
          try {
            result.add(mapFunction(item));
          } catch (e) {
            deboger(
                ['[ResponseMapper] item #$i ignoré : échec de mapping → $e', item]);
          }
        }
        return result;
      }

      // Si c'est un objet unique, le retourner dans une liste
      if (data is Map<String, dynamic>) {
        return [mapFunction(data)];
      }

      throw CustomException("Format de réponse non supporté");

    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException("Erreur lors du mapping des données: ${e.toString()}");
    }
  }

  /// Map une réponse API vers un modèle unique ou une liste de modèles
  ///
  /// [response] - La réponse Dio à mapper
  /// [fromJson] - Fonction de mapping pour un objet simple
  /// [fromJsonAll] - Fonction de mapping pour objets avec héritage (optionnel)
  ///
  /// Retourne:
  /// - Liste&lt;T&gt; si la réponse contient un array
  /// - T si la réponse contient un objet unique
  /// - Lance CustomException en cas d'erreur
  static dynamic mapResponse<T>({
    required Response response,
    required T Function(Map<String, dynamic>) fromJson,
    T Function(Map<String, dynamic>)? fromJsonAll,
  }) {
    // Vérifier les erreurs HTTP
    if (hasError(response)) {
      throw CustomException(response.statusMessage ?? "Erreur de réponse");
    }

    // Vérifier si la réponse contient des données
    if (response.data == null) {
      throw CustomException("Aucune donnée reçue");
    }

    try {
      final data = response.data;
      final mapFunction = fromJsonAll ?? fromJson;

      // Si c'est une liste, mapper chaque élément
      if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return mapFunction(item);
          } else {
            throw CustomException("Format de données invalide dans la liste");
          }
        }).toList().cast<T>();
      }

      // Si c'est un objet unique
      if (data is Map<String, dynamic>) {
        return [mapFunction(data)];
      }

      throw CustomException("Format de réponse non supporté");

    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException("Erreur lors du mapping des données: ${e.toString()}");
    }
  }

  /// Version simplifiée pour mapper directement vers une liste
  static List<T> mapToList<T>({
    required Response response,
    required T Function(Map<String, dynamic>) fromJson,
    T Function(Map<String, dynamic>)? fromJsonAll,
  }) {
    final result = mapResponse<T>(
      response: response,
      fromJson: fromJson,
      fromJsonAll: fromJsonAll,
    );

    if (result is List<T>) {
      return result;
    }

    throw CustomException("La réponse ne peut pas être mappée vers une liste");
  }

  /// Version simplifiée pour mapper directement vers un objet unique
  static T mapToObject<T>({
    required Response response,
    required T Function(Map<String, dynamic>) fromJson,
    T Function(Map<String, dynamic>)? fromJsonAll,
  }) {
    final result = mapResponse<T>(
      response: response,
      fromJson: fromJson,
      fromJsonAll: fromJsonAll,
    );

    if (result is List<T> && result.isNotEmpty) {
      return result.first;
    }

    throw CustomException("La réponse ne peut pas être mappée vers un objet unique");
  }
}