import 'package:web_flutter/model/favorite/user_favorite.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/service/dio/dio_request.dart';

class FavoriteService {
  /// Récupère les IDs des appartements favoris de l'utilisateur
  Future<List<int>> getUserFavoriteIds() async {
    final dio = DioRequest.instance;
    final response = await dio.get("auth/user/favorites");

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
    final response = await dio.get("auth/user/favorites");

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
    return await dio.getMapped<Appartement>("auth/appartement/favorites");
  }

  /// Ajoute un appartement aux favoris
  Future<void> addToFavorites(int apartId) async {
    final dio = DioRequest.instance;
    await dio.post("auth/user/favorites/$apartId");
  }

  /// Retire un appartement des favoris
  Future<void> removeFromFavorites(int apartId) async {
    final dio = DioRequest.instance;
    await dio.delete("auth/user/favorites/$apartId");
  }

  /// Toggle un favori (ajoute ou retire selon l'état actuel)
  Future<bool> toggleFavorite(int apartId, bool currentlyFavorite) async {
    if (currentlyFavorite) {
      await removeFromFavorites(apartId);
      return false;
    } else {
      await addToFavorites(apartId);
      return true;
    }
  }

  /// Synchronise les favoris locaux avec le serveur
  Future<List<int>> syncFavorites(List<int> localFavorites) async {
    try {
      // Récupérer les favoris du serveur
      final serverFavorites = await getUserFavoriteIds();

      // Trouver les différences
      final toAdd = localFavorites.where((id) => !serverFavorites.contains(id)).toList();
      final toRemove = serverFavorites.where((id) => !localFavorites.contains(id)).toList();

      // Synchroniser vers le serveur
      for (final id in toAdd) {
        try {
          await addToFavorites(id);
        } catch (e) {
          // Ignorer les erreurs individuelles lors de la sync
        }
      }

      for (final id in toRemove) {
        try {
          await removeFromFavorites(id);
        } catch (e) {
          // Ignorer les erreurs individuelles lors de la sync
        }
      }

      // Retourner l'état final du serveur
      return await getUserFavoriteIds();
    } catch (e) {
      // En cas d'erreur de sync, retourner les favoris locaux
      return localFavorites;
    }
  }
}