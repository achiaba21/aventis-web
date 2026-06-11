import 'package:asfar/model/compte/compte_proprietaire.dart';
import 'package:asfar/model/compte/demande_retrait.dart';
import 'package:asfar/model/compte/transaction.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service API pour la gestion des comptes propriétaires
class CompteApiService {
  static const String _baseEndpoint = "api/v1/comptes";

  /// Récupère le compte du propriétaire connecté
  Future<CompteProprietaire> getCompteProprietaire() async {
    final DioRequest dio = DioRequest.instance;

    deboger(['[CompteApiService] Récupération du compte propriétaire']);

    final response = await dio.get("$_baseEndpoint/proprietaire");

    final Map<String, dynamic>? compteJson = ResponseMapper.tryExtractBody(response.data);
    if (compteJson != null) {
      return CompteProprietaire.fromJson(compteJson);
    }

    throw Exception("Format de réponse invalide lors de la récupération du compte");
  }

  /// Récupère l'historique des transactions
  Future<List<Transaction>> getTransactions({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? limit,
    int? offset,
  }) async {
    final DioRequest dio = DioRequest.instance;

    final Map<String, String> queryParams = {};
    if (dateDebut != null) {
      queryParams['dateDebut'] = _formatDate(dateDebut);
    }
    if (dateFin != null) {
      queryParams['dateFin'] = _formatDate(dateFin);
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (offset != null) {
      queryParams['offset'] = offset.toString();
    }

    String endpoint = "$_baseEndpoint/transactions";
    if (queryParams.isNotEmpty) {
      final String queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint += '?$queryString';
    }

    deboger(['[CompteApiService] Récupération transactions: $endpoint']);

    final response = await dio.get(endpoint);

    final List<dynamic>? bodyList = ResponseMapper.tryExtractBodyList(response.data);
    if (bodyList != null) {
      return _parseTransactionList(bodyList);
    }

    return [];
  }

  /// Crée une demande de retrait
  Future<DemandeRetrait> createDemandeRetrait(double montant) async {
    final DioRequest dio = DioRequest.instance;

    deboger(['[CompteApiService] Création demande retrait: $montant']);

    final response = await dio.post(
      "$_baseEndpoint/retraits",
      data: {'montant': montant},
    );

    final Map<String, dynamic>? retraitJson = ResponseMapper.tryExtractBody(response.data);
    if (retraitJson != null) {
      return DemandeRetrait.fromJson(retraitJson);
    }

    throw Exception("Format de réponse invalide lors de la création de la demande");
  }

  /// Récupère les demandes de retrait
  Future<List<DemandeRetrait>> getDemandesRetrait() async {
    final DioRequest dio = DioRequest.instance;

    deboger(['[CompteApiService] Récupération demandes de retrait']);

    final response = await dio.get("$_baseEndpoint/retraits");

    final List<dynamic>? bodyList = ResponseMapper.tryExtractBodyList(response.data);
    if (bodyList != null) {
      return _parseDemandeRetraitList(bodyList);
    }

    return [];
  }

  // ==================== Méthodes privées (helpers) ====================

  List<Transaction> _parseTransactionList(dynamic listData) {
    if (listData is! List<dynamic>) return [];
    return listData
        .whereType<Map<String, dynamic>>()
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  List<DemandeRetrait> _parseDemandeRetraitList(dynamic listData) {
    if (listData is! List<dynamic>) return [];
    return listData
        .whereType<Map<String, dynamic>>()
        .map((json) => DemandeRetrait.fromJson(json))
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
