import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart' as events;
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/main.dart' show scaffoldMessengerKey;
import 'package:asfar/service/realtime/realtime_action_handler.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/theme/app_colors.dart';

class WebSocketInitializer extends StatefulWidget {
  final Widget child;

  const WebSocketInitializer({
    super.key,
    required this.child,
  });

  @override
  State<WebSocketInitializer> createState() => _WebSocketInitializerState();
}

class _WebSocketInitializerState extends State<WebSocketInitializer>
    with WidgetsBindingObserver {
  bool _isWebSocketInitialized = false;
  bool _hasShownConnectionError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialiser le RealtimeActionHandler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RealtimeActionHandler.instance.initialize(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App reprend, reprendre le handler et reconnexion si nécessaire
        RealtimeActionHandler.instance.resume();
        _checkWebSocketConnection();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App en arrière-plan, mettre en pause le handler
        RealtimeActionHandler.instance.pause();
        break;

      case AppLifecycleState.detached:
        // App fermée
        RealtimeActionHandler.instance.dispose();
        break;

      case AppLifecycleState.hidden:
        // App cachée (nouveau depuis Flutter 3.13)
        RealtimeActionHandler.instance.pause();
        break;
    }
  }

  void _checkWebSocketConnection() {
    final notificationBloc = context.read<NotificationBloc>();
    if (!notificationBloc.isWebSocketConnected) {
      notificationBloc.add(const events.ReconnectWebSocket());
    }
  }

  void _initializeWebSocketForUser(String userPhone, {String? authToken}) {
    if (_isWebSocketInitialized) return;

    final notificationBloc = context.read<NotificationBloc>();

    // Initialiser WebSocket
    notificationBloc.add(events.InitializeNotifications(
      userPhone: userPhone,
      authToken: authToken,
    ));

    // Initialiser FCM (Firebase Cloud Messaging) pour les notifications push
    notificationBloc.add(const events.InitializeFCM());

    _isWebSocketInitialized = true;
    deboger('🔌 WebSocket + FCM initialisés pour l\'utilisateur: $userPhone');
  }

  void _disconnectWebSocket() {
    if (!_isWebSocketInitialized) return;

    final notificationBloc = context.read<NotificationBloc>();
    notificationBloc.add(const events.DisconnectWebSocket());

    _isWebSocketInitialized = false;
    deboger('🔌 WebSocket déconnecté');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is UserLoaded) {
          // Utilisateur connecté, initialiser WebSocket
          final userPhone = userState.loadedUser.telephone;
          if (userPhone != null && userPhone.isNotEmpty) {
            // Récupérer le token d'authentification depuis le stockage
            final authToken = StorageService.instance.getToken();
            _initializeWebSocketForUser(userPhone, authToken: authToken);
          }
        } else if (userState is UserInitial) {
          // Utilisateur déconnecté, fermer WebSocket
          _disconnectWebSocket();
        }
      },
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, notificationState) {
          // Mettre à jour le contexte du RealtimeActionHandler
          RealtimeActionHandler.instance.updateContext(context);

          // Gérer les états de notification
          if (notificationState is NotificationReceivedState) {
            _showNotificationToast(notificationState.notification.displayTitle);
          } else if (notificationState is WebSocketError) {
            // N'afficher l'erreur qu'une seule fois
            if (!_hasShownConnectionError) {
              _hasShownConnectionError = true;
              _showConnectionError();
            }
          } else if (notificationState is WebSocketConnected) {
            // Afficher "Connexion rétablie" si on avait perdu la connexion
            if (_hasShownConnectionError) {
              _hasShownConnectionError = false;
              _showConnectionRestored();
            }
          }
        },
        child: widget.child,
      ),
    );
  }

  void _showNotificationToast(String title) {
    // Utiliser la clé globale pour accéder au ScaffoldMessenger
    // car WebSocketInitializer est au-dessus de MaterialApp dans l'arbre
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      deboger('⚠️ ScaffoldMessenger non disponible pour afficher la notification');
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Voir',
          textColor: AppColors.white,
          onPressed: () {
            // Navigation vers la page des notifications
            // Navigator.pushNamed(context, '/notifications');
          },
        ),
      ),
    );
  }

  void _showConnectionError() {
    // Utiliser la clé globale pour accéder au ScaffoldMessenger
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      deboger('⚠️ ScaffoldMessenger non disponible pour afficher l\'erreur');
      return;
    }

    // Fermer les snackbars précédents
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: AppColors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Connexion au serveur perdue. Reconnexion en cours...'),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showConnectionRestored() {
    // Utiliser la clé globale pour accéder au ScaffoldMessenger
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      deboger('⚠️ ScaffoldMessenger non disponible');
      return;
    }

    // Fermer les snackbars précédents
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi, color: AppColors.white, size: 20),
            SizedBox(width: 8),
            Text('Connexion rétablie'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}