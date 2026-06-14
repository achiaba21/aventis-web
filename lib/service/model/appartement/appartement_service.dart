import 'dart:convert';
import 'package:asfar/util/function.dart';
import 'package:dio/dio.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/filter/filter_options.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/model/forms/uploaded_image.dart';
import 'package:asfar/util/response/response_mapper.dart';

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
  static final urlGetAppartements = "api/appartement/apparts";

  /// Récupère tous les appartements avec mapping automatique
  ///
  /// [page] / [size] (optionnels) : pagination côté serveur. Sans ces
  /// paramètres, l'appel reste strictement identique (liste complète).
  Future<List<Appartement>> getAppartements({int? page, int? size}) async {
    final dio = DioRequest.instance;
    if (page != null || size != null) {
      return await dio.getMapped<Appartement>(
        urlGetAppartements,
        queryParameters: {
          if (page != null) 'page': page,
          if (size != null) 'size': size,
        },
      );
    }
    return await dio.getMapped<Appartement>(urlGetAppartements);
  }

  /// Récupère un appartement par ID
  Future<Appartement> getAppartementById(int id) async {
    final dio = DioRequest.instance;
    final result = await dio.getMapped<Appartement>("api/appartement/$id");

    if (result.isEmpty) {
      throw Exception("Appartement non trouvé");
    }

    return result.first;
  }

  /// Supprime un appartement
  Future<void> deleteAppartement(int id) async {
    final dio = DioRequest.instance;
    await dio.delete("api/appartement/$id");
  }

  // ==================== Modération (actions propriétaire) ====================
  // Endpoints à body vide, enveloppe ResponseServeur { body, message }.
  // Le message d'erreur backend (400) est relayé par l'intercepteur Dio.

  /// Met une annonce EN_LIGNE hors ligne (→ HORS_LIGNE).
  Future<Map<String, dynamic>> mettreHorsLigne(int id) async {
    final dio = DioRequest.instance;
    final response =
        await dio.post("api/proprietaire/appartement/$id/mettre-hors-ligne");
    return ResponseMapper.extractBody(response.data);
  }

  /// Remet une annonce HORS_LIGNE en ligne (→ EN_LIGNE, sans re-modération).
  Future<Map<String, dynamic>> remettreEnLigne(int id) async {
    final dio = DioRequest.instance;
    final response =
        await dio.post("api/proprietaire/appartement/$id/remettre-en-ligne");
    return ResponseMapper.extractBody(response.data);
  }

  /// Resoumet une annonce REFUSER à la modération (→ EN_COURS).
  Future<Map<String, dynamic>> resoumettre(int id) async {
    final dio = DioRequest.instance;
    final response =
        await dio.post("api/proprietaire/appartement/$id/resoumettre");
    return ResponseMapper.extractBody(response.data);
  }

  /// Récupère tous les appartements d'un propriétaire spécifique
  Future<List<Appartement>> getAppartementsByOwner(int proprietaireId) async {
    final dio = DioRequest.instance;
    return await dio.getMapped<Appartement>("api/appartement/apparts/$proprietaireId");
  }

  /// Récupère les appartements filtrés selon les critères
  Future<List<Appartement>> getFilteredAppartements(FilterCriteria criteria) async {
    final dio = DioRequest.instance;
    return await dio.postMapped<Appartement>(
      "api/appartement/filter",
      data: criteria.toJson(),
    );
  }

  /// Récupère les options de filtrage disponibles
  Future<FilterOptions> getFilterOptions() async {
    final dio = DioRequest.instance;
    final response = await dio.get("api/appartement/filter-options");
    return FilterOptions.fromJson(response.data);
  }

  /// Récupère les appartements du propriétaire connecté
  Future<List<Appartement>> getProprietaireAppartements() async {
    final dio = DioRequest.instance;
    return await dio
        .getMapped<Appartement>("api/proprietaire/appartement/appartements");
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
    return ResponseMapper.extractBody(response.data);
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

    return ResponseMapper.extractBody(response.data);
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

    return ResponseMapper.extractBody(response.data);
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
}
