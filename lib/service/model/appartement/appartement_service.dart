import 'dart:convert';
import 'package:asfar/util/function.dart';
import 'package:dio/dio.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/filter/filter_options.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/widget/form/image_uploader.dart';

/// Service API des appartements.
///
/// Pour les opérations d'**écriture** (création, mise à jour avec ou sans
/// images), ce service accepte un `Map<String, dynamic>` déjà préparé
/// (généralement par [AppartementBackendMapper]) et retourne un `Map`
/// brut depuis le backend. Le parsing en [Appartement] est de la
/// responsabilité du Repository (qui peut alors extraire l'ID de la
/// résidence backend via le mapper).
///
/// Pour les opérations de **lecture**, on continue d'utiliser
/// `dio.getMapped<Appartement>` qui s'appuie sur `Appartement.fromJson`.
/// Cette dernière fait la fusion défensive `residence.address → address`.
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

  /// Récupère les appartements du propriétaire connecté
  Future<List<Appartement>> getProprietaireAppartements() async {
    final dio = DioRequest.instance;
    return await dio.getMapped<Appartement>("api/proprietaire/appartement/appartements");
  }

  /// Crée un nouvel appartement (JSON pur, sans images).
  ///
  /// Le [payload] doit avoir été préparé par [AppartementBackendMapper.toCreatePayload].
  /// Retourne le `Map` brut du backend (à parser via mapper.fromBackendDto).
  Future<Map<String, dynamic>> saveAppartement(Map<String, dynamic> payload) async {
    final dio = DioRequest.instance;
    final response = await dio.post(
      "api/proprietaire/appartement/new",
      data: payload,
    );
    return _extractBodyMap(response.data);
  }

  /// Crée un appartement avec images (multipart/form-data).
  ///
  /// Le [payload] doit avoir été préparé par [AppartementBackendMapper.toCreatePayload].
  /// Les `photos` sont retirées du payload (gérées via les fichiers multipart).
  Future<Map<String, dynamic>> saveAppartementWithImages(
    Map<String, dynamic> payload,
    List<UploadedImage> images,
  ) async {
    final dio = DioRequest.instance;

    final cleaned = Map<String, dynamic>.from(payload)..remove('photos');

    final imageFiles = await _toMultipartFiles(images);

    final formData = FormData();
    formData.files.add(MapEntry(
      'appartement',
      MultipartFile.fromString(
        jsonEncode(cleaned),
        contentType: DioMediaType.parse('application/json'),
      ),
    ));
    formData.files.addAll(imageFiles.map((image) => MapEntry('images', image)));

    final response = await dio.postFormData(
      "api/proprietaire/appartement/new-with-images",
      formData: formData,
      onSendProgress: (sent, total) {
        deboger("Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%");
      },
    );

    return _extractBodyMap(response.data);
  }

  /// Met à jour un appartement existant avec images (multipart/form-data).
  ///
  /// Le [payload] doit avoir été préparé par [AppartementBackendMapper.toUpdatePayload]
  /// avec `backendResidenceId` pour préserver la cohérence côté serveur.
  ///
  /// `photosToDelete` : UUIDs des photos existantes à supprimer.
  Future<Map<String, dynamic>> updateAppartementWithImages(
    int appartementId,
    Map<String, dynamic> payload,
    List<UploadedImage> newImages, {
    List<String>? photosToDelete,
  }) async {
    final dio = DioRequest.instance;

    final cleaned = Map<String, dynamic>.from(payload)..remove('photos');

    final imageFiles = await _toMultipartFiles(newImages);

    final formData = FormData();
    formData.files.add(MapEntry(
      'appartement',
      MultipartFile.fromString(
        jsonEncode(cleaned),
        contentType: DioMediaType.parse('application/json'),
      ),
    ));
    if (imageFiles.isNotEmpty) {
      formData.files.addAll(imageFiles.map((image) => MapEntry('images', image)));
    }
    if (photosToDelete != null && photosToDelete.isNotEmpty) {
      for (final uuid in photosToDelete) {
        formData.fields.add(MapEntry('photosToDelete', uuid));
      }
    }

    final response = await dio.putFormData(
      "api/proprietaire/appartement/$appartementId",
      formData: formData,
      onSendProgress: (sent, total) {
        deboger("Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%");
      },
    );

    return _extractBodyMap(response.data);
  }

  // ============== Helpers privés ==============

  Future<List<MultipartFile>> _toMultipartFiles(List<UploadedImage> images) async {
    final List<MultipartFile> files = [];
    for (final image in images) {
      if (image.file != null && image.path.isNotEmpty) {
        try {
          final multipartFile = await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          );
          files.add(multipartFile);
        } catch (e) {
          deboger("Erreur lors de l'ajout de l'image ${image.name}: $e");
        }
      }
    }
    return files;
  }

  /// Extrait le `body` d'une réponse Spring (`{body: {...}, message: "..."}`)
  /// ou retourne directement la map si la réponse est plate.
  Map<String, dynamic> _extractBodyMap(dynamic data) {
    if (data is Map) {
      final responseMap = Map<String, dynamic>.from(data);
      final body = responseMap['body'];
      if (body is Map) {
        return Map<String, dynamic>.from(body);
      }
      if (responseMap.containsKey('id')) {
        return responseMap;
      }
    }
    throw Exception("Format de réponse invalide");
  }
}
