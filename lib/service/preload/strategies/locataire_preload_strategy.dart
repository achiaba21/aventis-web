import 'package:asfar/service/preload/preload_strategy.dart';

/// Stratégie de préchargement pour les utilisateurs locataires
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : définir la stratégie de préchargement pour les locataires
///
/// Principe SOLID - Open/Closed (O) :
/// Ouverte à l'extension (nouvelle stratégie), fermée à la modification
class LocatairePreloadStrategy implements IPreloadStrategy {
  @override
  List<PreloadDataType> getPreloadDataTypes() {
    return [
      // Résidences (priorité 0 - critique)
      // Les résidences contiennent les appartements qui seront extraits
      // et synchronisés vers AppartementBloc via le cascade pattern
      PreloadDataType.residences,

      // Favoris de l'utilisateur (priorité 1)
      PreloadDataType.favorites,

      // Réservations de l'utilisateur (priorité 2)
      PreloadDataType.reservations,

      // Notifications (priorité 2 - cache-first)
      PreloadDataType.notifications,

      // Conversations (priorité 3)
      PreloadDataType.conversations,
    ];
  }

  @override
  Map<PreloadDataType, int> getDataPriorities() {
    return {
      // Priorité 0 : Données critiques (affichées immédiatement)
      // Les résidences sont la source unique, elles alimentent AppartementBloc
      PreloadDataType.residences: 0,

      // Priorité 1 : Données importantes (utilisées fréquemment)
      PreloadDataType.favorites: 1,

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
    // donc doivent être chargées séquentiellement après l'initialisation WebSocket
    if (dataType == PreloadDataType.conversations) {
      return false;
    }

    // Résidences, favoris et réservations sont indépendants
    // et peuvent être chargés en parallèle
    return true;
  }
}
