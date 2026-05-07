/// Types de données pouvant être préchargées
/// Chaque type correspond à un domaine de données de l'application
enum PreloadDataType {
  /// Appartements disponibles (locataire) ou gérés (propriétaire)
  appartements,

  /// Résidences gérées par le propriétaire
  residences,

  /// Favoris de l'utilisateur
  favorites,

  /// Réservations de l'utilisateur
  reservations,

  /// Conversations/messages de l'utilisateur
  conversations,

  /// Notifications de l'utilisateur (géré séparément via WebSocket)
  notifications,

  /// Données de localités (pays, villes, etc.)
  localities,
}

/// Interface définissant une stratégie de préchargement de données
///
/// Principe SOLID - Interface Segregation (I) :
/// Interface minimale avec seulement les méthodes nécessaires
///
/// Principe SOLID - Dependency Inversion (D) :
/// Les clients dépendent de cette abstraction, pas d'implémentations concrètes
abstract class IPreloadStrategy {
  /// Retourne la liste des types de données à précharger
  /// selon la stratégie (rôle utilisateur, contexte, etc.)
  List<PreloadDataType> getPreloadDataTypes();

  /// Retourne un dictionnaire associant chaque type de données à sa priorité
  /// Priorité 0 = la plus haute (chargée en premier)
  /// Priorité 10+ = la plus basse (chargée en dernier)
  Map<PreloadDataType, int> getDataPriorities();

  /// Détermine si un type de données peut être préchargé en parallèle
  /// avec d'autres types de même priorité
  ///
  /// Retourne true si le chargement peut être parallélisé
  /// Retourne false si le chargement doit être séquentiel (ex: dépendances)
  bool canPreloadInParallel(PreloadDataType dataType);
}
