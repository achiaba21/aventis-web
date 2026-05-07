import 'package:asfar/service/preload/preload_strategy.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Coordinateur central pour orchestrer le préchargement des données
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : orchestrer le préchargement selon la stratégie définie
///
/// Principe SOLID - Dependency Inversion (D) :
/// Dépend de l'abstraction IPreloadStrategy, pas d'implémentations concrètes
///
/// Principe SOLID - Open/Closed (O) :
/// Ouvert à l'extension (nouvelles stratégies/executors), fermé à la modification
class DataPreloadCoordinator {
  final IPreloadStrategy _strategy;
  final Map<PreloadDataType, PreloadExecutor> _executors;

  DataPreloadCoordinator({
    required IPreloadStrategy strategy,
    required Map<PreloadDataType, PreloadExecutor> executors,
  })  : _strategy = strategy,
        _executors = executors;

  /// Lance le préchargement transparent (non-bloquant)
  ///
  /// Cette méthode :
  /// 1. Récupère la liste des données à précharger depuis la stratégie
  /// 2. Groupe les données par niveau de priorité
  /// 3. Pour chaque niveau de priorité :
  ///    - Exécute en parallèle les données qui peuvent l'être
  ///    - Exécute séquentiellement les autres
  /// 4. Gère les erreurs sans bloquer le processus global
  ///
  /// Retourne un Future qui se complète quand tout le préchargement est terminé
  Future<void> startPreloading() async {
    try {
      deboger(['[DataPreloadCoordinator] Démarrage du préchargement']);

      final dataTypes = _strategy.getPreloadDataTypes();
      final priorities = _strategy.getDataPriorities();

      deboger(['[DataPreloadCoordinator] Types de données à précharger: $dataTypes']);

      // Grouper par priorité
      final groupedByPriority = _groupByPriority(dataTypes, priorities);

      deboger(['[DataPreloadCoordinator] Niveaux de priorité: ${groupedByPriority.keys.toList()..sort()}']);

      // Charger par vagues de priorité (ordre croissant = priorité décroissante)
      final sortedPriorities = groupedByPriority.keys.toList()..sort();

      for (final priority in sortedPriorities) {
        final dataTypesForPriority = groupedByPriority[priority]!;

        deboger(['[DataPreloadCoordinator] Traitement priorité $priority: $dataTypesForPriority']);

        // Déterminer quels types peuvent se charger en parallèle
        final parallelTypes = dataTypesForPriority
            .where((type) => _strategy.canPreloadInParallel(type))
            .toList();

        final sequentialTypes = dataTypesForPriority
            .where((type) => !_strategy.canPreloadInParallel(type))
            .toList();

        // Charger en parallèle
        if (parallelTypes.isNotEmpty) {
          deboger(['[DataPreloadCoordinator] Chargement parallèle: $parallelTypes']);

          await Future.wait(
            parallelTypes.map((type) => _executePreload(type)),
          );
        }

        // Charger séquentiellement
        if (sequentialTypes.isNotEmpty) {
          deboger(['[DataPreloadCoordinator] Chargement séquentiel: $sequentialTypes']);

          for (final type in sequentialTypes) {
            await _executePreload(type);
          }
        }
      }

      deboger(['[DataPreloadCoordinator] Préchargement terminé avec succès']);
    } catch (e) {
      // Log l'erreur mais ne propage pas l'exception
      // Le préchargement est transparent et ne doit pas bloquer l'application
      deboger(['[DataPreloadCoordinator] Erreur globale lors du préchargement: $e']);
    }
  }

  /// Exécute le préchargement pour un type de données spécifique
  ///
  /// Les erreurs sont catchées et loggées sans bloquer les autres préchargements
  Future<void> _executePreload(PreloadDataType dataType) async {
    final executor = _executors[dataType];

    if (executor == null) {
      deboger(['[DataPreloadCoordinator] Aucun executor trouvé pour $dataType']);
      return;
    }

    try {
      deboger(['[DataPreloadCoordinator] Exécution du préchargement pour $dataType']);
      await executor.execute();
      deboger(['[DataPreloadCoordinator] Préchargement réussi pour $dataType']);
    } catch (e) {
      // Log l'erreur mais ne bloque pas les autres préchargements
      deboger(['[DataPreloadCoordinator] Erreur préchargement $dataType: $e']);
    }
  }

  /// Groupe les types de données par niveau de priorité
  ///
  /// Les données sans priorité explicite reçoivent une priorité par défaut de 10
  Map<int, List<PreloadDataType>> _groupByPriority(
    List<PreloadDataType> dataTypes,
    Map<PreloadDataType, int> priorities,
  ) {
    final grouped = <int, List<PreloadDataType>>{};

    for (final type in dataTypes) {
      final priority = priorities[type] ?? 10; // Priorité par défaut
      grouped.putIfAbsent(priority, () => []).add(type);
    }

    return grouped;
  }
}
