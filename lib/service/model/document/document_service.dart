import 'dart:io';
import 'package:dio/dio.dart';
import 'package:asfar/model/document/identity_document.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service réseau du KYC (vérification d'identité).
///
/// Consomme `/api/user/documents` (enveloppe `ResponseServeur { body, message }`).
/// Le token Bearer est injecté automatiquement par [DioRequest]. Les erreurs
/// métier (400 avec message backend) remontent telles quelles : le message est
/// déjà extrait par l'intercepteur Dio.
class DocumentService {
  final DioRequest _dio = DioRequest.instance;

  /// Récupère tous les documents de l'utilisateur courant (tous statuts).
  Future<List<IdentityDocument>> getMyDocuments() async {
    final response = await _dio.get("api/user/documents");
    final body = ResponseMapper.tryExtractBodyList(response.data);
    if (body == null) return const [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(IdentityDocument.fromJson)
        .toList(growable: false);
  }

  /// Envoie une pièce justificative (multipart : `file` + `titre`).
  Future<IdentityDocument> uploadDocument({
    required File file,
    required String titre,
  }) async {
    final formData = FormData.fromMap({
      'titre': titre,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await _dio.postFormData(
      "api/user/documents",
      formData: formData,
    );

    final body = ResponseMapper.tryExtractBody(response.data);
    if (body == null) {
      throw Exception('Réponse serveur invalide');
    }
    return IdentityDocument.fromJson(body);
  }
}
