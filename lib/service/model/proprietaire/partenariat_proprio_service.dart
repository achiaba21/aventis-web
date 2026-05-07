import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class PartenariatProprioService {
  final DioRequest _dio = DioRequest.instance;

  static const _urlDemandes = 'api/proprietaire/partenariat/demandes';

  Future<List<DemandePartenariat>> getDemandes() async {
    try {
      deboger('[PartenariatProprioService] getDemandes');
      final response = await _dio.get(_urlDemandes);
      final serverResponse = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (body) =>
            (body as List? ?? [])
                .map(
                  (e) => DemandePartenariat.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );
      return serverResponse.body;
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_GET_DEMANDES_PROPRIO', e);
      rethrow;
    }
  }

  Future<void> accepterDemande(int id) async {
    try {
      deboger('[PartenariatProprioService] accepterDemande id=$id');
      await _dio.post('$_urlDemandes/$id/accepter');
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_ACCEPTER', e);
      rethrow;
    }
  }

  Future<void> refuserDemande(int id) async {
    try {
      deboger('[PartenariatProprioService] refuserDemande id=$id');
      await _dio.post('$_urlDemandes/$id/refuser');
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_REFUSER', e);
      rethrow;
    }
  }
}
