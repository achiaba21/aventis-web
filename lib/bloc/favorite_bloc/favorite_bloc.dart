import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_state.dart';
import 'package:web_flutter/service/model/favorite/favorite_service.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  late FavoriteService favoriteService;
  static const String _favoritesKey = 'user_favorites';

  FavoriteBloc() : super(FavoriteInitial()) {
    favoriteService = FavoriteService();

    on<LoadFavorites>((event, emit) async {
      emit(FavoriteLoading());
      try {
        // Charger d'abord depuis le cache local
        final cachedFavorites = await _loadCachedFavorites();
        if (cachedFavorites.isNotEmpty) {
          emit(FavoriteLoaded(cachedFavorites));
        }

        // Puis charger depuis le serveur
        final serverFavorites = await favoriteService.getUserFavoriteIds();
        deboger(["favorites loaded from server:", serverFavorites]);

        // Sauvegarder en cache
        await _saveCachedFavorites(serverFavorites);
        emit(FavoriteLoaded(serverFavorites));
      } on CustomException catch (e) {
        deboger(["favorite error:", e]);
        final cachedFavorites = await _loadCachedFavorites();
        emit(FavoriteError(
          e.message,
          favoriteIds: cachedFavorites,
          originalEvent: event,
        ));
      } on DioException catch (e) {
        deboger(["dio error:", e]);
        final cachedFavorites = await _loadCachedFavorites();
        emit(FavoriteError(
          e.response?.data?.toString() ?? "Erreur de connexion",
          favoriteIds: cachedFavorites,
          originalEvent: event,
        ));
      } catch (e) {
        deboger(["unexpected error:", e]);
        final cachedFavorites = await _loadCachedFavorites();
        emit(FavoriteError(
          "Une erreur est survenue",
          favoriteIds: cachedFavorites,
          originalEvent: event,
        ));
      }
    });

    on<ToggleFavorite>((event, emit) async {
      final currentState = state;
      if (currentState is! FavoriteLoaded && currentState is! FavoriteError) {
        return;
      }

      final currentFavorites = _getCurrentFavoriteIds();
      final isCurrentlyFavorite = currentFavorites.contains(event.apartId);

      // Mise à jour optimiste immédiate
      final newFavorites = List<int>.from(currentFavorites);
      if (isCurrentlyFavorite) {
        newFavorites.remove(event.apartId);
      } else {
        newFavorites.add(event.apartId);
      }

      emit(FavoriteOptimisticUpdate(newFavorites, event.apartId, !isCurrentlyFavorite));

      try {
        // Synchronisation serveur
        final newState = await favoriteService.toggleFavorite(event.apartId, isCurrentlyFavorite);

        // Sauvegarder en cache
        await _saveCachedFavorites(newFavorites);

        emit(FavoriteActionSuccess(
          newFavorites,
          newState ? "Ajouté aux favoris" : "Retiré des favoris",
          affectedApartId: event.apartId,
        ));

        // Retour à l'état normal après 2 secondes
        await Future.delayed(Duration(seconds: 2));
        if (state is FavoriteActionSuccess) {
          emit(FavoriteLoaded(newFavorites));
        }
      } catch (e) {
        deboger(["toggle favorite error:", e]);

        // Rollback en cas d'erreur
        await _saveCachedFavorites(currentFavorites);

        String errorMessage = "Impossible de modifier les favoris";
        if (e is DioException) {
          errorMessage = e.response?.data?.toString() ?? "Erreur de connexion";
        } else if (e is CustomException) {
          errorMessage = e.message;
        }

        emit(FavoriteError(
          errorMessage,
          favoriteIds: currentFavorites,
          originalEvent: event,
        ));
      }
    });

    on<AddToFavorites>((event, emit) async {
      final currentFavorites = _getCurrentFavoriteIds();
      if (currentFavorites.contains(event.apartId)) {
        return; // Déjà dans les favoris
      }

      final newFavorites = List<int>.from(currentFavorites)..add(event.apartId);
      emit(FavoriteOptimisticUpdate(newFavorites, event.apartId, true));

      try {
        await favoriteService.addToFavorites(event.apartId);
        await _saveCachedFavorites(newFavorites);
        emit(FavoriteActionSuccess(newFavorites, "Ajouté aux favoris"));

        await Future.delayed(Duration(seconds: 2));
        if (state is FavoriteActionSuccess) {
          emit(FavoriteLoaded(newFavorites));
        }
      } catch (e) {
        await _saveCachedFavorites(currentFavorites);
        emit(FavoriteError(
          _getErrorMessage(e),
          favoriteIds: currentFavorites,
          originalEvent: event,
        ));
      }
    });

    on<RemoveFromFavorites>((event, emit) async {
      final currentFavorites = _getCurrentFavoriteIds();
      if (!currentFavorites.contains(event.apartId)) {
        return; // Pas dans les favoris
      }

      final newFavorites = List<int>.from(currentFavorites)..remove(event.apartId);
      emit(FavoriteOptimisticUpdate(newFavorites, event.apartId, false));

      try {
        await favoriteService.removeFromFavorites(event.apartId);
        await _saveCachedFavorites(newFavorites);
        emit(FavoriteActionSuccess(newFavorites, "Retiré des favoris"));

        await Future.delayed(Duration(seconds: 2));
        if (state is FavoriteActionSuccess) {
          emit(FavoriteLoaded(newFavorites));
        }
      } catch (e) {
        await _saveCachedFavorites(currentFavorites);
        emit(FavoriteError(
          _getErrorMessage(e),
          favoriteIds: currentFavorites,
          originalEvent: event,
        ));
      }
    });

    on<LoadFavoriteAppartements>((event, emit) async {
      emit(FavoriteLoading());
      try {
        final appartements = await favoriteService.getFavoriteAppartements();
        final favoriteIds = appartements.map((app) => app.id!).toList();
        emit(FavoriteAppartementsLoaded(appartements, favoriteIds));
      } catch (e) {
        emit(FavoriteError(_getErrorMessage(e), originalEvent: event));
      }
    });

    on<SyncFavorites>((event, emit) async {
      emit(FavoriteSyncing(event.localFavorites));
      try {
        final syncedFavorites = await favoriteService.syncFavorites(event.localFavorites);
        await _saveCachedFavorites(syncedFavorites);

        final hasChanges = !_listsEqual(event.localFavorites, syncedFavorites);
        emit(FavoriteSynced(syncedFavorites, hasChanges));

        // Retour à l'état normal
        await Future.delayed(Duration(seconds: 1));
        if (state is FavoriteSynced) {
          emit(FavoriteLoaded(syncedFavorites));
        }
      } catch (e) {
        emit(FavoriteError(
          _getErrorMessage(e),
          favoriteIds: event.localFavorites,
          originalEvent: event,
        ));
      }
    });

    on<RetryFailedAction>((event, emit) async {
      add(event.originalEvent);
    });
  }

  List<int> _getCurrentFavoriteIds() {
    final currentState = state;
    if (currentState is FavoriteLoaded) return currentState.favoriteIds;
    if (currentState is FavoriteError) return currentState.favoriteIds ?? [];
    if (currentState is FavoriteOptimisticUpdate) return currentState.favoriteIds;
    if (currentState is FavoriteActionSuccess) return currentState.favoriteIds;
    if (currentState is FavoriteSyncing) return currentState.currentFavorites;
    if (currentState is FavoriteSynced) return currentState.favoriteIds;
    return [];
  }

  Future<List<int>> _loadCachedFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList(_favoritesKey) ?? [];
      return cached.map((id) => int.parse(id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveCachedFavorites(List<int> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites.map((id) => id.toString()).toList());
    } catch (e) {
      deboger(["failed to save favorites cache:", e]);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return error.response?.data?.toString() ?? "Erreur de connexion";
    } else if (error is CustomException) {
      return error.message;
    } else {
      return "Une erreur est survenue";
    }
  }

  bool _listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}