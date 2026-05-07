import 'package:asfar/service/preload/preload_strategy.dart';

/// Stratégie de préchargement pour les utilisateurs propriétaires
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : définir la stratégie de préchargement pour les propriétaires
///
/// Principe SOLID - Open/Closed (O) :
/// Ouverte à l'extension (nouvelle stratégie), fermée à la modification
class ProprioPreloadStrategy implements IPreloadStrategy {
  @override
  List<PreloadDataType> getPreloadDataTypes() {
    return [
      // Résidences du propriétaire (priorité 0 - critique)
      PreloadDataType.residences,

      // Appartements du propriétaire (priorité 0 - chargé depuis cache Hive)
      PreloadDataType.appartements,

      // Réservations des propriétés (priorité 2)
      PreloadDataType.reservations,

      // Notifications (priorité 2 - cache-first)
      PreloadDataType.notifications,

      // Conversations avec locataires (priorité 3)
      PreloadDataType.conversations,
    ];
  }

  @override
  Map<PreloadDataType, int> getDataPriorities() {
    return {
      // Priorité 0 : Données critiques (cache Hive)
      // Résidences et appartements sont chargés depuis le cache local
      // puis rafraîchis en arrière-plan depuis l'API
      PreloadDataType.residences: 0,
      PreloadDataType.appartements: 0,

      // Priorité 2 : Données contextuelles
      PreloadDataType.reservations: 2,
      PreloadDataType.notifications: 2,

      // Priorité 3 : Données secondaires
      PreloadDataType.conversations: 3,
    };
  }

  @override
  bool canPreloadInParallel(PreloadDataType dataType) {
    // Les conversations dépendent de la connexion WebSocket
    // donc doivent être chargées séquentiellement
    if (dataType == PreloadDataType.conversations) {
      return false;
    }

    // Résidences et appartements sont chargés depuis cache Hive (rapide)
    // donc peuvent être en parallèle avec d'autres types
    return true;
  }
}
