import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Service neutre (sans préfixe de rôle) pour fetch des demandes de
/// partenariat — V9.2.
///
/// Distinct de `PartenariatProprioService` (qui a des actions liées au rôle
/// proprio : accepter, refuser). Ce service expose juste le lookup par ID
/// utilisé par la card système chat `AcceptedPartenariatMessageCard`.
///
/// Route backend : `GET /api/demande-partenariat/{id}` (sans préfixe rôle).
class PartenariatService {
  PartenariatService._internal();

  static final PartenariatService _instance = PartenariatService._internal();

  factory PartenariatService() => _instance;

  static const _urlBase = 'api/demande-partenariat';

  final DioRequest _dio = DioRequest.instance;

  Future<DemandePartenariat> getDemandeById(int id) async {
    try {
      deboger('[PartenariatService] getDemandeById id=$id');
      final response = await _dio.get('$_urlBase/$id');
      final serverResponse = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (body) => DemandePartenariat.fromJson(body as Map<String, dynamic>),
      );
      return serverResponse.body;
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_GET_BY_ID', e);
      rethrow;
    }
  }
}
