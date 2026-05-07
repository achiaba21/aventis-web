import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class PartenariatDemarcheurService {
  final DioRequest _dio = DioRequest.instance;

  static const _urlDemande = 'api/demarcheur/partenariat/demande';
  static const _urlDemandes = 'api/demarcheur/partenariat/demandes';

  Future<DemandePartenariat> sendDemande(String telephone) async {
    try {
      deboger('[PartenariatDemarcheurService] sendDemande tel=$telephone');
      final response = await _dio.post(
        _urlDemande,
        data: {'telephone': telephone},
      );
      final serverResponse = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (body) => DemandePartenariat.fromJson(body as Map<String, dynamic>),
      );
      return serverResponse.body;
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_SEND_DEMANDE', e);
      rethrow;
    }
  }

  Future<List<DemandePartenariat>> getDemandes() async {
    try {
      deboger('[PartenariatDemarcheurService] getDemandes');
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
      ErrorHandler.logError('PARTENARIAT_GET_DEMANDES_DEMARCHEUR', e);
      rethrow;
    }
  }
}
