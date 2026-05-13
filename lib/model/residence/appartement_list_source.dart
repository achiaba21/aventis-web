/// Source/contexte d'une liste d'appartements émis par `AppartementBloc`.
///
/// Permet aux consommateurs (preload executor, UI conditionnelle) de
/// distinguer le contexte d'origine sans avoir besoin de sous-classes de state.
enum AppartementListSource {
  /// Feed locataire — endpoint public `auth/appartement/apparts` (cache-first
  /// via `AppartementRepository.getAllAppartements`).
  all,

  /// Liste filtrée par propriétaire spécifique — endpoint
  /// `auth/appartement/apparts/{ownerId}`. L'`ownerId` est porté par le state.
  byOwner,

  /// Mes appartements (proprio connecté) — endpoint privé
  /// `api/proprietaire/appartement/appartements` (cache-first via
  /// `AppartementRepository.getProprietaireAppartements`).
  proprietaire,
}
