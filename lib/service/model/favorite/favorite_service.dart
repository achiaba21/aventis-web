import 'package:asfar/model/favorite/user_favorite.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/response/favorite_appartements_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

class FavoriteService {
  /// Récupère les IDs des appartements favoris de l'utilisateur
  Future<List<int>> getUserFavoriteIds() async {
    final dio = DioRequest.instance;
    final response = await dio.get("api/user/favorites");

    // Gérer la structure {body: [...], message: "..."} ou une liste à plat
    final body = ResponseMapper.tryExtractBodyList(response.data);
    if (body != null) {
      return List<int>.from(body.map((item) {
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
    final response = await dio.get("api/user/favorites");
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
    final response = await dio.get("api/user/favorites/apartments");
    final favoriteResponse = FavoriteAppartementsResponse.fromJson(response.data);
    return favoriteResponse.body;
  }

  /// Toggle un favori (ajoute ou retire selon l'état actuel)
  /// Utilise le nouvel endpoint POST /api/user/favorites/{apartmentId}/toggle
  Future<bool> toggleFavorite(int apartId, bool currentlyFavorite) async {
    final dio = DioRequest.instance;
    await dio.post("api/user/favorites/$apartId/toggle");

    // Le serveur retourne le nouvel état (true = ajouté, false = supprimé)
    // On retourne l'inverse de l'état actuel
    return !currentlyFavorite;
  }
}