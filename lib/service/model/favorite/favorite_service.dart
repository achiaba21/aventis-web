import 'package:asfar/model/favorite/user_favorite.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/response/favorite_appartements_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

class FavoriteService {
  /// Récupère les IDs des appartements favoris de l'utilisateur
  Future<List<int>> getUserFavoriteIds() async {
    final dio = DioRequest.instance;
    final response = await dio.get("user/favorites");

    // Gérer la nouvelle structure de réponse {body: [...], message: "..."}
    if (response.data is Map<String, dynamic>) {
      final responseMap = response.data as Map<String, dynamic>;
      final body = responseMap['body'];

      if (body is List) {
        return List<int>.from(body.map((item) {
          if (item is int) return item;
          if (item is Map<String, dynamic>) {
            return item['apartId'] ?? item['apartment_id'] ?? item['appartement_id'];
          }
          return null;
        }).where((id) => id != null));
      }
    }

    // Fallback pour l'ancienne structure (au cas où)
    if (response.data is List) {
      return List<int>.from(response.data.map((item) {
        if (item is int) return item;
        if (item is Map<String, dynamic>) {
          return item['apartId'] ?? item['apartment_id'] ?? item['appartement_id'];
        }
        return null;
      }).where((id) => id != null));
    }

    return [];
  }

  /// Récupère les favoris complets avec détails
  Future<List<UserFavorite>> getUserFavorites() async {
    final dio = DioRequest.instance;
    final response = await dio.get("user/favorites");
    deboger([response.data,response.statusCode]);
    if (response.data is List) {
      return List<UserFavorite>.from(
        response.data.map((item) => UserFavorite.fromJson(item))
      );
    }

    return [];
  }

  /// Récupère les appartements favoris complets
  Future<List<Appartement>> getFavoriteAppartements() async {
    final dio = DioRequest.instance;
    final response = await dio.get("user/favorites/apartments");
    final favoriteResponse = FavoriteAppartementsResponse.fromJson(response.data);
    return favoriteResponse.body;
  }

  /// Toggle un favori (ajoute ou retire selon l'état actuel)
  /// Utilise le nouvel endpoint POST /user/favorites/{apartmentId}/toggle
  Future<bool> toggleFavorite(int apartId, bool currentlyFavorite) async {
    final dio = DioRequest.instance;
    await dio.post("user/favorites/$apartId/toggle");

    // Le serveur retourne le nouvel état (true = ajouté, false = supprimé)
    // On retourne l'inverse de l'état actuel
    return !currentlyFavorite;
  }
}