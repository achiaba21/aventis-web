import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/notification_bloc/notification_bloc.dart';
import 'package:web_flutter/bloc/notification_bloc/notification_event.dart' as events;
import 'package:web_flutter/bloc/notification_bloc/notification_state.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/service/realtime/realtime_action_handler.dart';
import 'package:web_flutter/util/function.dart';

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
    notificationBloc.add(events.InitializeNotifications(
      userPhone: userPhone,
      authToken: authToken,
    ));

    _isWebSocketInitialized = true;
    deboger('🔌 WebSocket initialisé pour l\'utilisateur: $userPhone');
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
          final userPhone = userState.user.telephone;
          if (userPhone != null && userPhone.isNotEmpty) {
            _initializeWebSocketForUser(userPhone);
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
            _showConnectionError(notificationState.errorMessage);
          }
        },
        child: widget.child,
      ),
    );
  }

  void _showNotificationToast(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            // Navigation vers la page des notifications
            // Navigator.pushNamed(context, '/notifications');
          },
        ),
      ),
    );
  }

  void _showConnectionError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Erreur de connexion: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: () {
            context.read<NotificationBloc>().add(const events.ReconnectWebSocket());
          },
        ),
      ),
    );
  }
}