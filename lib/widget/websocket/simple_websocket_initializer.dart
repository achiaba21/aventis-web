import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/service/websocket/websocket_manager.dart';
import 'package:asfar/service/realtime/realtime_action_handler.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/theme/app_colors.dart';

class SimpleWebSocketInitializer extends StatefulWidget {
  final Widget child;

  const SimpleWebSocketInitializer({
    super.key,
    required this.child,
  });

  @override
  State<SimpleWebSocketInitializer> createState() => _SimpleWebSocketInitializerState();
}

class _SimpleWebSocketInitializerState extends State<SimpleWebSocketInitializer>
    with WidgetsBindingObserver {
  final WebSocketManager _webSocketManager = WebSocketManager.instance;
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
    if (!_webSocketManager.isConnected) {
      _webSocketManager.reconnect();
    }
  }

  Future<void> _initializeWebSocketForUser(String userPhone, {String? authToken}) async {
    if (_isWebSocketInitialized) return;

    try {
      await _webSocketManager.initialize(
        userPhone: userPhone,
        authToken: authToken,
      );

      _isWebSocketInitialized = true;
      deboger('🔌 WebSocket initialisé pour l\'utilisateur: $userPhone');

      // Afficher un message de connexion
      if (mounted) {
        _showConnectionStatus('WebSocket connecté', AppColors.success);
      }

    } catch (e) {
      deboger('❌ Erreur initialisation WebSocket: $e');
      if (mounted) {
        _showConnectionStatus('Erreur de connexion WebSocket', AppColors.error);
      }
    }
  }

  Future<void> _disconnectWebSocket() async {
    if (!_isWebSocketInitialized) return;

    try {
      await _webSocketManager.disconnect();
      _isWebSocketInitialized = false;
      deboger('🔌 WebSocket déconnecté');

      if (mounted) {
        _showConnectionStatus('WebSocket déconnecté', AppColors.warning);
      }

    } catch (e) {
      deboger('❌ Erreur déconnexion WebSocket: $e');
    }
  }

  void _showConnectionStatus(String message, Color color) {
    try {
      // Vérifier si ScaffoldMessenger est disponible dans le contexte
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  color == AppColors.success ? Icons.wifi : Icons.wifi_off,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(message),
              ],
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        // Fallback: log uniquement si ScaffoldMessenger n'est pas disponible
        deboger('📱 Status WebSocket: $message');
      }
    } catch (e) {
      // En cas d'erreur, log uniquement
      deboger('📱 Status WebSocket: $message (erreur affichage: $e)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, userState) {
        if (userState is UserLoaded) {
          // Utilisateur connecté, initialiser WebSocket
          final userPhone = userState.loadedUser.telephone;
          if (userPhone != null && userPhone.isNotEmpty) {
            _initializeWebSocketForUser(userPhone);
          }

          // Charger les favoris de l'utilisateur
          context.read<FavoriteBloc>().add(LoadFavorites());
        } else if (userState is UserInitial) {
          // Utilisateur déconnecté, fermer WebSocket
          _disconnectWebSocket();
        }
      },
      child: StreamBuilder(
        stream: _webSocketManager.stateStream,
        builder: (context, snapshot) {
          // Mettre à jour le contexte du service
          RealtimeActionHandler.instance.updateContext(context);
          return widget.child;
        },
      ),
    );
  }
}