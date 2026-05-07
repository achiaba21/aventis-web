abstract class FavoriteEvent {}

/// Charge les favoris depuis le serveur
class LoadFavorites extends FavoriteEvent {}

/// Toggle un favori (optimiste - UI immédiate + sync serveur)
class ToggleFavorite extends FavoriteEvent {
  final int apartId;
  ToggleFavorite(this.apartId);
}

/// Réessaie une action qui a échoué
class RetryFailedAction extends FavoriteEvent {
  final FavoriteEvent originalEvent;
  RetryFailedAction(this.originalEvent);
}

/// Effacer tous les favoris (utilisé lors de la déconnexion)
class ClearAllFavorites extends FavoriteEvent {}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
class ResetFavoriteState extends FavoriteEvent {}