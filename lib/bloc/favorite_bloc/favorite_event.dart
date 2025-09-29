abstract class FavoriteEvent {}

/// Charge les favoris depuis le serveur
class LoadFavorites extends FavoriteEvent {}

/// Ajoute un appartement aux favoris
class AddToFavorites extends FavoriteEvent {
  final int apartId;
  AddToFavorites(this.apartId);
}

/// Retire un appartement des favoris
class RemoveFromFavorites extends FavoriteEvent {
  final int apartId;
  RemoveFromFavorites(this.apartId);
}

/// Toggle un favori (optimiste - UI immédiate + sync serveur)
class ToggleFavorite extends FavoriteEvent {
  final int apartId;
  ToggleFavorite(this.apartId);
}

/// Synchronise les favoris locaux avec le serveur
class SyncFavorites extends FavoriteEvent {
  final List<int> localFavorites;
  SyncFavorites(this.localFavorites);
}

/// Réessaie une action qui a échoué
class RetryFailedAction extends FavoriteEvent {
  final FavoriteEvent originalEvent;
  RetryFailedAction(this.originalEvent);
}