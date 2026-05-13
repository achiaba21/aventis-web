import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service API pour la gestion des charges
///
/// Gère les appels au serveur pour le CRUD des charges uniquement.
/// Les calculs comptables sont effectués côté client via ComptabiliteCalculator.
class ComptabiliteApiService {
  /// Préfixe de base pour tous les endpoints comptabilité
  static const String _baseEndpoint = "api/v1/comptabilite";

  /// Crée une nouvelle charge sur le serveur
  Future<Charge> createCharge(Charge charge) async {
    final DioRequest dio = DioRequest.instance;

    final Map<String, dynamic> chargeData = charge.toJson();
    // Retirer l'ID local si présent (le serveur génère l'ID)
    chargeData.remove('id');

    deboger(['[ComptabiliteApiService] Création charge: $chargeData']);

    final response = await dio.post(
      "$_baseEndpoint/charges",
      data: chargeData,
    );

    final Map<String, dynamic>? chargeJson = _extractBodyAsMap(response.data);
    if (chargeJson != null) {
      return Charge.fromJson(chargeJson);
    }

    throw Exception("Format de réponse invalide lors de la création de charge");
  }

  /// Met à jour une charge existante sur le serveur
  Future<Charge> updateCharge(Charge charge) async {
    if (charge.id == null) {
      throw Exception("ID de charge requis pour la mise à jour");
    }

    final DioRequest dio = DioRequest.instance;

    deboger(['[ComptabiliteApiService] Mise à jour charge: ${charge.id}']);

    final response = await dio.put(
      "$_baseEndpoint/charges/${charge.id}",
      data: charge.toJson(),
    );

    final Map<String, dynamic>? chargeJson = _extractBodyAsMap(response.data);
    if (chargeJson != null) {
      return Charge.fromJson(chargeJson);
    }

    throw Exception("Format de réponse invalide lors de la mise à jour de charge");
  }

  /// Supprime une charge sur le serveur
  Future<void> deleteCharge(int chargeId) async {
    final DioRequest dio = DioRequest.instance;

    deboger(['[ComptabiliteApiService] Suppression charge: $chargeId']);

    await dio.delete("$_baseEndpoint/charges/$chargeId");
  }

  /// Récupère toutes les charges.
  ///
  /// Filtres disponibles : `appartementId`, `dateDebut`, `dateFin`.
  /// (Les filtres `residenceId` et `estPaye` ont été retirés du backend
  /// le 2026-05-13 — toute charge en base est désormais un paiement déjà
  /// effectué.)
  Future<List<Charge>> getAllCharges({
    int? appartementId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final DioRequest dio = DioRequest.instance;

    final Map<String, String> queryParams = {};

    if (appartementId != null) {
      queryParams['appartementId'] = appartementId.toString();
    }
    if (dateDebut != null) {
      queryParams['dateDebut'] = _formatDate(dateDebut);
    }
    if (dateFin != null) {
      queryParams['dateFin'] = _formatDate(dateFin);
    }

    String endpoint = "$_baseEndpoint/charges";
    if (queryParams.isNotEmpty) {
      final String queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint += '?$queryString';
    }

    deboger(['[ComptabiliteApiService] Récupération charges: $endpoint']);

    final response = await dio.get(endpoint);

    final List<dynamic>? bodyList = _extractBodyAsList(response.data);
    if (bodyList != null) {
      return _parseChargeList(bodyList);
    }

    return [];
  }

  /// Récupère une charge par son ID
  Future<Charge> getChargeById(int chargeId) async {
    final DioRequest dio = DioRequest.instance;

    deboger(['[ComptabiliteApiService] Récupération charge: $chargeId']);

    final response = await dio.get("$_baseEndpoint/charges/$chargeId");

    final Map<String, dynamic>? chargeJson = _extractBodyAsMap(response.data);
    if (chargeJson != null) {
      return Charge.fromJson(chargeJson);
    }

    throw Exception("Charge non trouvée: $chargeId");
  }

  // ==================== Méthodes privées (helpers) ====================

  /// Extrait le body de la réponse en tant que Map
  /// Gère les deux formats: {body: {...}} et {...} directement
  Map<String, dynamic>? _extractBodyAsMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Format {body: {...}, message: "..."}
      final dynamic bodyRaw = responseData['body'];
      if (bodyRaw is Map<String, dynamic>) {
        return bodyRaw;
      }

      // Fallback: la réponse est directement l'objet
      if (responseData.containsKey('id')) {
        return responseData;
      }
    }
    return null;
  }

  /// Extrait le body de la réponse en tant que List
  /// Gère les deux formats: {body: [...]} et [...] directement
  List<dynamic>? _extractBodyAsList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final dynamic bodyRaw = responseData['body'];
      if (bodyRaw is List<dynamic>) {
        return bodyRaw;
      }
    }

    if (responseData is List<dynamic>) {
      return responseData;
    }

    return null;
  }

  /// Parse une liste de Charge depuis une liste dynamique
  List<Charge> _parseChargeList(dynamic listData) {
    if (listData is! List<dynamic>) return [];

    return listData
        .whereType<Map<String, dynamic>>()
        .map((json) => Charge.fromJson(json))
        .toList();
  }

  /// Formate une date au format YYYY-MM-DD (attendu par l'API)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
