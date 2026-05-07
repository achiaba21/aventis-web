import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Service API pour la gestion des démarcheurs partenaires d'un propriétaire
class ProprietaireDemarcheurService {
  final DioRequest _dio = DioRequest.instance;

  static const _urlBase = 'api/proprietaire/demarcheurs';

  /// Récupère la liste des démarcheurs liés au propriétaire connecté
  ///
  /// GET proprietaire/demarcheurs
  Future<List<Demarcheur>> getDemarcheurs() async {
    try {
      deboger('[ProprietaireDemarcheurService] getDemarcheurs');
      final response = await _dio.get(_urlBase);
      final sr = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (b) => (b as List<dynamic>)
            .map((e) => Demarcheur.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return sr.body;
    } catch (e) {
      ErrorHandler.logError('PROPRIO_GET_DEMARCHEURS', e);
      rethrow;
    }
  }

  /// Lie un démarcheur au propriétaire via son numéro de téléphone
  ///
  /// POST proprietaire/demarcheurs/link { telephone }
  Future<void> linkDemarcheur(String telephone) async {
    try {
      deboger('[ProprietaireDemarcheurService] linkDemarcheur tel=$telephone');
      await _dio.post('$_urlBase/link', data: {'telephone': telephone});
    } catch (e) {
      ErrorHandler.logError('PROPRIO_LINK_DEMARCHEUR', e);
      rethrow;
    }
  }

  /// Délie un démarcheur du propriétaire
  ///
  /// DELETE proprietaire/demarcheurs/{id}/unlink
  Future<void> unlinkDemarcheur(int id) async {
    try {
      deboger('[ProprietaireDemarcheurService] unlinkDemarcheur id=$id');
      await _dio.delete('$_urlBase/$id/unlink');
    } catch (e) {
      ErrorHandler.logError('PROPRIO_UNLINK_DEMARCHEUR', e);
      rethrow;
    }
  }
}
