import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Executor pour précharger les notifications de l'utilisateur
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : précharger les données des notifications
///
/// Note: Les notifications utilisent un système cache-first avec WebSocket.
/// Cet executor charge les données en cache immédiatement puis depuis l'API.
class NotificationPreloadExecutor implements PreloadExecutor {
  final NotificationBloc _notificationBloc;

  NotificationPreloadExecutor({
    required NotificationBloc notificationBloc,
  }) : _notificationBloc = notificationBloc;

  @override
  Future<void> execute() async {
    try {
      // Vérifier si les données sont déjà chargées
      final currentState = _notificationBloc.state;

      // NotificationBloc utilise un cache-first pattern
      // Les données peuvent déjà être disponibles
      if (currentState is NotificationLoaded) {
        deboger(['[NotificationPreloadExecutor] Données déjà chargées, skip preload']);
        return;
      }

      deboger(['[NotificationPreloadExecutor] Démarrage du préchargement']);

      // Déclencher le chargement (cache-first + API + WebSocket)
      _notificationBloc.add(const LoadNotifications());

      // Attendre la fin du chargement avec timeout
      // Timeout plus court car utilise cache + WebSocket
      await _notificationBloc.stream
          .firstWhere(
            (state) =>
                state is NotificationLoaded ||
                state is NotificationError,
            orElse: () => _notificationBloc.state,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              deboger(['[NotificationPreloadExecutor] Timeout après 8 secondes']);
              return _notificationBloc.state;
            },
          );

      deboger(['[NotificationPreloadExecutor] Préchargement terminé']);
    } catch (e) {
      // Log l'erreur mais ne bloque pas le préchargement global
      deboger(['[NotificationPreloadExecutor] Erreur lors du préchargement: $e']);
    }
  }
}
