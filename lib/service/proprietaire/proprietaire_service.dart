import 'package:dio/dio.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Service pour charger les infos du propriétaire à la demande
/// Utilisé par les locataires pour voir les infos du proprio après paiement
///
/// Pattern cache-first :
/// 1. Vérifie le cache local (Hive)
/// 2. Si pas en cache, appelle l'API
/// 3. Sauvegarde en cache si succès
/// 4. Retourne null si 403 (pas autorisé)
class ProprietaireService {
  // Singleton
  static final ProprietaireService _instance = ProprietaireService._internal();
  factory ProprietaireService() => _instance;
  ProprietaireService._internal();

  final StorageService _storage = StorageService.instance;

  /// Récupère le propriétaire depuis le cache ou l'API
  ///
  /// Retourne le Proprietaire si :
  /// - Présent en cache, ou
  /// - L'utilisateur a une réservation payée (API retourne 200)
  ///
  /// Retourne null si :
  /// - Pas de réservation payée (API retourne 403)
  /// - Erreur réseau
  Future<Proprietaire?> getProprietaire(int appartementId) async {
    // 1. Vérifier le cache
    final cached = getCachedProprietaire(appartementId);
    if (cached != null) {
      deboger(['[ProprietaireService] Cache hit pour appartement $appartementId']);
      return cached;
    }

    // 2. Appeler l'API
    deboger(['[ProprietaireService] Cache miss, appel API pour appartement $appartementId']);
    return _fetchFromApi(appartementId);
  }

  /// Récupère depuis le cache uniquement (synchrone)
  Proprietaire? getCachedProprietaire(int appartementId) {
    try {
      final data = _storage.getProprietaire(appartementId);
      if (data == null) return null;
      return Proprietaire.fromJson(data);
    } catch (e) {
      deboger(['[ProprietaireService] Erreur lecture cache: $e']);
      return null;
    }
  }

  /// Appel API pour récupérer les infos du propriétaire
  ///
  /// Endpoint: GET /appartement/{appartementId}/proprietaire
  /// - 200: Retourne les infos (réservation payée)
  /// - 403: Pas autorisé (pas de réservation payée)
  Future<Proprietaire?> _fetchFromApi(int appartementId) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('appartement/$appartementId/proprietaire');

      if (response.data != null) {
        Map<String, dynamic> proprietaireData;

        // Gérer différents formats de réponse
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          // Si la réponse a un 'body', l'utiliser
          if (responseMap.containsKey('body') && responseMap['body'] != null) {
            proprietaireData = Map<String, dynamic>.from(responseMap['body']);
          } else {
            proprietaireData = responseMap;
          }
        } else {
          deboger(['[ProprietaireService] Format de réponse invalide']);
          return null;
        }

        // Sauvegarder en cache
        await _storage.saveProprietaire(appartementId, proprietaireData);

        return Proprietaire.fromJson(proprietaireData);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        deboger(['[ProprietaireService] 403 - Pas autorisé pour appartement $appartementId']);
        return null;
      }
      deboger(['[ProprietaireService] Erreur API: ${e.message}']);
      return null;
    } catch (e) {
      deboger(['[ProprietaireService] Erreur inattendue: $e']);
      return null;
    }
  }

  /// Vide le cache des propriétaires
  Future<void> clearCache() async {
    await _storage.clearProprietaires();
    deboger('[ProprietaireService] Cache vidé');
  }
}
