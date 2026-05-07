import 'package:asfar/model/locolite/lieux/pays.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service pour gérer les opérations liées aux pays
class PaysService {
  static const String _urlLieux = "api/lieux";

  /// Récupère la liste de tous les pays
  Future<List<Pays>> getAllPays() async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays");

    deboger(["PaysService - getAllPays response:", response.data]);

    // Gérer la structure de réponse {body: [...], message: "..."}
    if (response.data is Map<String, dynamic>) {
      final responseMap = response.data as Map<String, dynamic>;
      final body = responseMap['body'];

      if (body is List) {
        return List<Pays>.from(
          body.map((item) => Pays.fromJson(item as Map<String, dynamic>)),
        );
      }
    }

    // Fallback pour une réponse directe en liste
    if (response.data is List) {
      return List<Pays>.from(
        response.data.map((item) => Pays.fromJson(item as Map<String, dynamic>)),
      );
    }

    return [];
  }

  /// Récupère un pays par son ID
  Future<Pays?> getPaysById(int id) async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays/$id");

    deboger(["PaysService - getPaysById response:", response.data]);

    // Gérer la structure de réponse {body: {...}, message: "..."}
    if (response.data is Map<String, dynamic>) {
      final responseMap = response.data as Map<String, dynamic>;
      final body = responseMap['body'];

      if (body is Map<String, dynamic>) {
        return Pays.fromJson(body);
      }

      // Fallback: peut-être que response.data est directement l'objet Pays
      if (responseMap.containsKey('id')) {
        return Pays.fromJson(responseMap);
      }
    }

    return null;
  }

  /// Récupère un pays par son code
  Future<Pays?> getPaysByCode(String code) async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays/$code");

    deboger(["PaysService - getPaysByCode response:", response.data]);

    // Gérer la structure de réponse
    if (response.data is Map<String, dynamic>) {
      final responseMap = response.data as Map<String, dynamic>;
      final body = responseMap['body'];

      if (body is Map<String, dynamic>) {
        return Pays.fromJson(body);
      }

      if (responseMap.containsKey('id')) {
        return Pays.fromJson(responseMap);
      }
    }

    return null;
  }
}
