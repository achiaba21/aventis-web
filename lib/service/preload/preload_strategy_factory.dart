import 'package:asfar/model/user/user.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/service/preload/preload_strategy.dart';
import 'package:asfar/service/preload/strategies/locataire_preload_strategy.dart';
import 'package:asfar/service/preload/strategies/proprio_preload_strategy.dart';

/// Factory pour créer la stratégie de préchargement appropriée
/// selon le type d'utilisateur
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : créer la stratégie appropriée
///
/// Principe SOLID - Dependency Inversion (D) :
/// Retourne une abstraction (IPreloadStrategy), pas une implémentation concrète
/// Les clients dépendent de l'abstraction, pas de la factory
class PreloadStrategyFactory {
  /// Crée une stratégie de préchargement adaptée au type d'utilisateur
  ///
  /// - Pour un Proprietaire : retourne ProprioPreloadStrategy
  /// - Pour un Locataire : retourne LocatairePreloadStrategy
  /// - Par défaut : retourne LocatairePreloadStrategy
  ///
  /// Principe SOLID - Liskov Substitution (L) :
  /// Toutes les stratégies retournées sont substituables via IPreloadStrategy
  static IPreloadStrategy createStrategy(User user) {
    if (user is Proprietaire) {
      return ProprioPreloadStrategy();
    } else if (user is Locataire) {
      return LocatairePreloadStrategy();
    } else {
      // Stratégie par défaut pour les types d'utilisateur non reconnus
      return LocatairePreloadStrategy();
    }
  }
}
