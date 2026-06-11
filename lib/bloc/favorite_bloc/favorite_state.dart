abstract class FavoriteState {
  /// Statut favori d'un appartement — `false` par défaut (Initial/Loading),
  /// surchargé par les états porteurs d'ids. Permet un `BlocSelector` ciblé
  /// par carte (PERF-03).
  bool isFavorite(int apartId) => false;
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

/// État avec les IDs des favoris
class FavoriteLoaded extends FavoriteState {
  final List<int> favoriteIds;
  final DateTime lastUpdated;

  FavoriteLoaded(this.favoriteIds, {DateTime? lastUpdated})
      : lastUpdated = lastUpdated ?? DateTime.now();

  @override
  bool isFavorite(int apartId) => favoriteIds.contains(apartId);

  FavoriteLoaded copyWith({List<int>? favoriteIds}) {
    return FavoriteLoaded(
      favoriteIds ?? this.favoriteIds,
      lastUpdated: DateTime.now(),
    );
  }
}

/// État d'optimisation - action immédiate en cours de sync
class FavoriteOptimisticUpdate extends FavoriteState {
  final List<int> favoriteIds;
  final int pendingApartId;
  final bool isPending; // true = ajout en cours, false = suppression en cours

  FavoriteOptimisticUpdate(this.favoriteIds, this.pendingApartId, this.isPending);

  @override
  bool isFavorite(int apartId) => favoriteIds.contains(apartId);
}

/// Action réussie avec feedback
class FavoriteActionSuccess extends FavoriteState {
  final List<int> favoriteIds;
  final String message;
  final int? affectedApartId;

  FavoriteActionSuccess(this.favoriteIds, this.message, {this.affectedApartId});

  @override
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

  @override
  bool isFavorite(int apartId) => favoriteIds?.contains(apartId) ?? false;
}