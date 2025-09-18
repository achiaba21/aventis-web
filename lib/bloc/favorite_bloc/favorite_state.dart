import 'package:web_flutter/model/residence/appart.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

/// État avec les IDs des favoris
class FavoriteLoaded extends FavoriteState {
  final List<int> favoriteIds;
  final DateTime lastUpdated;

  FavoriteLoaded(this.favoriteIds, {DateTime? lastUpdated})
      : lastUpdated = lastUpdated ?? DateTime.now();

  bool isFavorite(int apartId) => favoriteIds.contains(apartId);

  FavoriteLoaded copyWith({List<int>? favoriteIds}) {
    return FavoriteLoaded(
      favoriteIds ?? this.favoriteIds,
      lastUpdated: DateTime.now(),
    );
  }
}

/// État avec les appartements favoris complets
class FavoriteAppartementsLoaded extends FavoriteState {
  final List<Appartement> appartements;
  final List<int> favoriteIds;

  FavoriteAppartementsLoaded(this.appartements, this.favoriteIds);
}

/// État d'optimisation - action immédiate en cours de sync
class FavoriteOptimisticUpdate extends FavoriteState {
  final List<int> favoriteIds;
  final int pendingApartId;
  final bool isPending; // true = ajout en cours, false = suppression en cours

  FavoriteOptimisticUpdate(this.favoriteIds, this.pendingApartId, this.isPending);

  bool isFavorite(int apartId) => favoriteIds.contains(apartId);
}

/// Action réussie avec feedback
class FavoriteActionSuccess extends FavoriteState {
  final List<int> favoriteIds;
  final String message;
  final int? affectedApartId;

  FavoriteActionSuccess(this.favoriteIds, this.message, {this.affectedApartId});

  bool isFavorite(int apartId) => favoriteIds.contains(apartId);
}

/// Erreur avec possibilité de retry
class FavoriteError extends FavoriteState {
  final String message;
  final List<int>? favoriteIds; // État précédent préservé
  final dynamic originalEvent; // Pour retry
  final bool canRetry;

  FavoriteError(
    this.message, {
    this.favoriteIds,
    this.originalEvent,
    this.canRetry = true,
  });

  bool isFavorite(int apartId) => favoriteIds?.contains(apartId) ?? false;
}

/// État de synchronisation
class FavoriteSyncing extends FavoriteState {
  final List<int> currentFavorites;

  FavoriteSyncing(this.currentFavorites);

  bool isFavorite(int apartId) => currentFavorites.contains(apartId);
}

/// Synchronisation terminée
class FavoriteSynced extends FavoriteState {
  final List<int> favoriteIds;
  final bool hasChanges;

  FavoriteSynced(this.favoriteIds, this.hasChanges);

  bool isFavorite(int apartId) => favoriteIds.contains(apartId);
}