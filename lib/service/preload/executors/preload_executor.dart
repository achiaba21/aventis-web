/// Interface définissant un executor de préchargement pour un type de données
///
/// Principe SOLID - Single Responsibility (S) :
/// Chaque executor concret est responsable du préchargement d'UN seul type de données
///
/// Principe SOLID - Interface Segregation (I) :
/// Interface minimale avec une seule méthode
///
/// Principe SOLID - Liskov Substitution (L) :
/// Tous les executors peuvent être substitués de manière transparente
abstract class PreloadExecutor {
  /// Exécute le préchargement du type de données associé
  ///
  /// Cette méthode doit :
  /// - Vérifier si les données sont déjà chargées
  /// - Déclencher le chargement via le BLoC approprié
  /// - Attendre la complétion (avec timeout)
  /// - Gérer les erreurs sans bloquer l'exécution
  ///
  /// Retourne un Future qui se complète quand le chargement est terminé
  /// ou échoue (timeout, erreur réseau, etc.)
  Future<void> execute();
}
