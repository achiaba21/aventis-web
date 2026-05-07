import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/service/preload/data_preload_coordinator.dart';
import 'package:asfar/service/preload/preload_strategy.dart';
import 'package:asfar/service/preload/preload_strategy_factory.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/service/preload/executors/appartement_preload_executor.dart';
import 'package:asfar/service/preload/executors/favorite_preload_executor.dart';
import 'package:asfar/service/preload/executors/reservation_preload_executor.dart';
import 'package:asfar/service/preload/executors/notification_preload_executor.dart';
import 'package:asfar/service/preload/executors/conversation_preload_executor.dart';

/// Builder pour créer un DataPreloadCoordinator configuré
/// avec tous les executors nécessaires
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : construire le coordinateur avec ses dépendances
///
/// Principe SOLID - Dependency Inversion (D) :
/// Récupère les BLoCs depuis le contexte (abstraction via Provider)
class PreloadCoordinatorBuilder {
  /// Construit un DataPreloadCoordinator pour un utilisateur donné
  ///
  /// Récupère tous les BLoCs nécessaires depuis le BuildContext
  /// et crée les executors appropriés
  static DataPreloadCoordinator build(BuildContext context, User user) {
    // Créer la stratégie appropriée selon le type d'utilisateur
    final strategy = PreloadStrategyFactory.createStrategy(user);

    // Récupérer les BLoCs depuis le contexte
    final appartementBloc = context.read<AppartementBloc>();
    final favoriteBloc = context.read<FavoriteBloc>();
    final reservationBloc = context.read<ReservationBloc>();
    final notificationBloc = context.read<NotificationBloc>();
    final conversationBloc = context.read<ConversationBloc>();

    // Déterminer si l'utilisateur est propriétaire ou locataire
    final isProprietaire = user is Proprietaire;

    // Créer les executors (le préchargement résidence est retiré post BACKEND-FLAT-APPART)
    final executors = <PreloadDataType, PreloadExecutor>{
      PreloadDataType.appartements: AppartementPreloadExecutor(
        appartementBloc: appartementBloc,
        isProprietaire: isProprietaire,
      ),
      PreloadDataType.favorites: FavoritePreloadExecutor(
        favoriteBloc: favoriteBloc,
      ),
      PreloadDataType.reservations: ReservationPreloadExecutor(
        reservationBloc: reservationBloc,
        user: user,
      ),
      PreloadDataType.notifications: NotificationPreloadExecutor(
        notificationBloc: notificationBloc,
      ),
      PreloadDataType.conversations: ConversationPreloadExecutor(
        conversationBloc: conversationBloc,
      ),
    };

    // Créer et retourner le coordinateur
    return DataPreloadCoordinator(
      strategy: strategy,
      executors: executors,
    );
  }
}
