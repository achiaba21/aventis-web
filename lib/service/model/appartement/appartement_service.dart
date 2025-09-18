import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/filter/filter_options.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/service/dio/dio_request.dart';

class AppartementService {
  static final urlGetAppartements = "auth/appartement/apparts";

  /// Récupère tous les appartements avec mapping automatique
  Future<List<Appartement>> getAppartements() async {
    final dio = DioRequest.instance;
    return await dio.getMapped<Appartement>(urlGetAppartements);
  }

  /// Récupère un appartement par ID
  Future<Appartement> getAppartementById(int id) async {
    final dio = DioRequest.instance;
    final result = await dio.getMapped<Appartement>("auth/appartement/$id");

    if (result.isEmpty) {
      throw Exception("Appartement non trouvé");
    }

    return result.first;
  }

  /// Crée un nouvel appartement
  Future<Appartement> createAppartement(Appartement appartement) async {
    final dio = DioRequest.instance;
    final result = await dio.postMapped<Appartement>(
      "auth/appartement/create",
      data: appartement.toJson(),
    );

    return result.first;
  }

  /// Met à jour un appartement existant
  Future<Appartement> updateAppartement(Appartement appartement) async {
    final dio = DioRequest.instance;
    final result = await dio.putMapped<Appartement>(
      "auth/appartement/${appartement.id}",
      data: appartement.toJson(),
    );

    return result.first;
  }

  /// Supprime un appartement
  Future<void> deleteAppartement(int id) async {
    final dio = DioRequest.instance;
    await dio.delete("auth/appartement/$id");
  }

  /// Récupère tous les appartements d'un propriétaire spécifique
  Future<List<Appartement>> getAppartementsByOwner(int proprietaireId) async {
    final dio = DioRequest.instance;
    return await dio.getMapped<Appartement>("auth/appartement/apparts/$proprietaireId");
  }

  /// Récupère les appartements filtrés selon les critères
  Future<List<Appartement>> getFilteredAppartements(FilterCriteria criteria) async {
    final dio = DioRequest.instance;
    return await dio.postMapped<Appartement>(
      "auth/appartement/filter",
      data: criteria.toJson(),
    );
  }

  /// Récupère les options de filtrage disponibles
  Future<FilterOptions> getFilterOptions() async {
    final dio = DioRequest.instance;
    final response = await dio.get("auth/appartement/filter-options");
    return FilterOptions.fromJson(response.data);
  }
}