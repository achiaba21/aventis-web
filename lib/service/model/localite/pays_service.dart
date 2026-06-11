import 'package:asfar/model/locolite/lieux/pays.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service pour gérer les opérations liées aux pays
class PaysService {
  static const String _urlLieux = "api/lieux";

  /// Récupère la liste de tous les pays
  Future<List<Pays>> getAllPays() async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays");

    deboger(["PaysService - getAllPays response:", response.data]);

    // Gérer la structure {body: [...], message: "..."} ou une liste directe
    final body = ResponseMapper.tryExtractBodyList(response.data);
    if (body != null) {
      return List<Pays>.from(
        body.map((item) => Pays.fromJson(item as Map<String, dynamic>)),
      );
    }

    return [];
  }

  /// Récupère un pays par son ID
  Future<Pays?> getPaysById(int id) async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays/$id");

    deboger(["PaysService - getPaysById response:", response.data]);

    // Gérer la structure {body: {...}, message: "..."} ou l'objet à plat
    final body = ResponseMapper.tryExtractBody(response.data);
    if (body != null && body.containsKey('id')) {
      return Pays.fromJson(body);
    }

    return null;
  }

  /// Récupère un pays par son code
  Future<Pays?> getPaysByCode(String code) async {
    final dio = DioRequest.instance;
    final response = await dio.get("$_urlLieux/pays/$code");

    deboger(["PaysService - getPaysByCode response:", response.data]);

    // Gérer la structure {body: {...}, message: "..."} ou l'objet à plat
    final body = ResponseMapper.tryExtractBody(response.data);
    if (body != null && body.containsKey('id')) {
      return Pays.fromJson(body);
    }

    return null;
  }
}
