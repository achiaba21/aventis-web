import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart' as events;
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/notification/notification_service.dart';
import 'package:asfar/service/websocket/websocket_service.dart';
import 'package:asfar/service/firebase/fcm_service.dart';
import 'package:asfar/util/function.dart';
import 'dart:convert';

class NotificationBloc
    extends Bloc<events.NotificationEvent, NotificationState> {
  final WebSocketService _webSocketService = WebSocketService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final FCMService _fcmService = FCMService();

  // Subscriptions pour les streams WebSocket
  StreamSubscription<WebSocketState>? _webSocketStateSubscription;
  StreamSubscription<NotificationModel>? _notificationSubscription;

  // Subscriptions pour FCM
  StreamSubscription<NotificationModel>? _fcmNotificationSubscription;
  StreamSubscription<String>? _fcmTokenSubscription;

  // Cache local des notifications
  List<NotificationModel> _notifications = [];
  WebSocketState _currentWebSocketState = const WebSocketState();

  // Clé pour le stockage local
  static const String _notificationsKey = 'cached_notifications';
  static const String _unreadCountKey = 'unread_notifications_count';

  NotificationBloc() : super(const NotificationInitial()) {
    // Enregistrement des handlers d'événements
    on<events.InitializeNotifications>(_onInitializeNotifications);
    on<events.LoadNotifications>(_onLoadNotifications);
    on<events.NotificationReceived>(_onNotificationReceived);
    on<events.MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<events.MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<events.DeleteNotification>(_onDeleteNotification);
    on<events.ClearAllNotifications>(_onClearAllNotifications);
    on<events.RefreshNotifications>(_onRefreshNotifications);
    on<events.ConnectWebSocket>(_onConnectWebSocket);
    on<events.DisconnectWebSocket>(_onDisconnectWebSocket);
    on<events.ReconnectWebSocket>(_onReconnectWebSocket);
    on<events.WebSocketStateChanged>(_onWebSocketStateChanged);
    on<events.SendTestNotification>(_onSendTestNotification);
    on<events.ResetNotificationState>(_onResetNotificationState);

    // FCM handlers
    on<events.InitializeFCM>(_onInitializeFCM);
    on<events.FCMTokenReceived>(_onFCMTokenReceived);
    on<events.DeleteFCMToken>(_onDeleteFCMToken);

    // Initialisation des streams WebSocket
    _initializeWebSocketStreams();
  }

  void _initializeWebSocketStreams() {
    // Écoute des changements d'état WebSocket
    _webSocketStateSubscription = _webSocketService.stateStream.listen(
      (webSocketState) {
        _currentWebSocketState = webSocketState;
        add(events.WebSocketStateChanged(webSocketState));
      },
      onError: (error) {
        deboger('Erreur stream WebSocket state: $error');
      },
    );

    // Écoute des notifications reçues
    _notificationSubscription = _webSocketService.notificationStream.listen(
      (notification) {
        add(events.NotificationReceived(notification));
      },
      onError: (error) {
        deboger('Erreur stream notifications: $error');
      },
    );
  }

  Future<void> _onInitializeNotifications(
    events.InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      // Charger les notifications du cache local
      await _loadCachedNotifications();

      // Connecter le WebSocket
      await _webSocketService.connect(
        userPhone: event.userPhone,
        authToken: event.authToken,
      );

      emit(
        NotificationLoaded(
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ),
      );

      deboger(
        '✅ Notifications initialisées avec ${_notifications.length} notifications',
      );

      // Charger les notifications depuis l'API en arrière-plan
      try {
        final apiNotifications =
            await _notificationService.getUserNotifications();
        _notifications = apiNotifications.reversed.toList();
        await _saveCachedNotifications();

        emit(
          NotificationLoaded(
            notifications: _notifications,
            webSocketState: _currentWebSocketState,
            unreadCount: _getUnreadCount(),
          ),
        );

        deboger(
          '✅ ${apiNotifications.length} notifications chargées depuis l\'API',
        );
      } catch (apiError) {
        deboger(
          '❌ Erreur chargement API (continuons avec le cache): $apiError',
        );
      }
    } catch (e) {
      deboger('❌ Erreur initialisation notifications: $e');
      emit(
        NotificationError(
          message: 'Erreur lors de l\'initialisation: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onLoadNotifications(
    events.LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Charger d'abord depuis le cache local (immédiat)
      await _loadCachedNotifications();

      deboger(['📱 ${_notifications.length} notifications chargées du cache']);

      emit(
        NotificationLoaded(
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ),
      );

      // Puis charger depuis l'API en arrière-plan (transparent)
      try {
        final apiNotifications =
            await _notificationService.getUserNotifications();
        _notifications = apiNotifications.reversed.toList();
        await _saveCachedNotifications();

        emit(
          NotificationLoaded(
            notifications: _notifications,
            webSocketState: _currentWebSocketState,
            unreadCount: _getUnreadCount(),
          ),
        );

        deboger([
          '✅ ${apiNotifications.length} notifications chargées depuis l\'API',
        ]);
      } catch (apiError) {
        deboger([
          '❌ Erreur chargement API (continuons avec le cache): $apiError',
        ]);
        // Pas d'erreur émise, on continue avec le cache
      }
    } catch (e) {
      deboger(['❌ Erreur chargement notifications: $e']);
      emit(
        NotificationError(
          message: 'Erreur lors du chargement: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onNotificationReceived(
    events.NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Ajouter en tête de liste (plus récent en premier)
      _notifications.insert(0, event.notification);

      // Limiter le nombre de notifications en cache
      if (_notifications.length > 100) {
        _notifications = _notifications.take(100).toList();
      }

      // Sauvegarder en cache local
      await _saveCachedNotifications();

      emit(
        NotificationReceivedState(
          notification: event.notification,
          allNotifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ),
      );

      deboger(
        '✅ Nouvelle notification reçue: ${event.notification.displayTitle}',
      );
    } catch (e) {
      deboger('❌ Erreur traitement notification reçue: $e');
    }
  }

  Future<void> _onMarkNotificationAsRead(
    events.MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final index = _notifications.indexWhere(
        (n) => n.id == event.notificationId,
      );

      if (index != -1) {
        // Sauvegarder l'ancienne notification pour rollback en cas d'erreur
        final oldNotification = _notifications[index];

        // Mise à jour optimiste (UI immédiate)
        _notifications[index] = _notifications[index].markAsRead();
        await _saveCachedNotifications();

        emit(
          NotificationActionSuccess(
            message: 'Notification marquée comme lue',
            notifications: _notifications,
            webSocketState: _currentWebSocketState,
            unreadCount: _getUnreadCount(),
          ),
        );

        // Appel API en arrière-plan
        try {
          await _notificationService.markAsRead(event.notificationId);
          deboger(
            '✅ Notification ${event.notificationId} marquée comme lue (API)',
          );
        } catch (apiError) {
          // Rollback en cas d'erreur API
          deboger('❌ Erreur API markAsRead, rollback: $apiError');
          _notifications[index] = oldNotification;
          await _saveCachedNotifications();

          emit(
            NotificationError(
              message: 'Erreur lors du marquage: $apiError',
              webSocketState: _currentWebSocketState,
            ),
          );
        }
      }
    } catch (e) {
      deboger('❌ Erreur marquage notification lue: $e');
      emit(
        NotificationError(
          message: 'Erreur lors du marquage: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    events.MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Sauvegarder l'ancienne liste pour rollback
      final oldNotifications = List<NotificationModel>.from(_notifications);

      // Mise à jour optimiste (UI immédiate)
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      await _saveCachedNotifications();

      emit(
        NotificationActionSuccess(
          message: 'Toutes les notifications marquées comme lues',
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: 0,
        ),
      );

      // Appel API en arrière-plan
      try {
        await _notificationService.markAllAsRead();
        deboger('✅ Toutes les notifications marquées comme lues (API)');
      } catch (apiError) {
        // Rollback en cas d'erreur API
        deboger('❌ Erreur API markAllAsRead, rollback: $apiError');
        _notifications = oldNotifications;
        await _saveCachedNotifications();

        emit(
          NotificationError(
            message: 'Erreur lors du marquage: $apiError',
            webSocketState: _currentWebSocketState,
          ),
        );
      }
    } catch (e) {
      deboger('❌ Erreur marquage toutes notifications lues: $e');
      emit(
        NotificationError(
          message: 'Erreur lors du marquage: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onDeleteNotification(
    events.DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Sauvegarder la notification supprimée pour rollback
      final deletedNotification = _notifications.firstWhere(
        (n) => n.id == event.notificationId,
        orElse: () => throw Exception('Notification non trouvée'),
      );
      final deletedIndex = _notifications.indexOf(deletedNotification);

      // Mise à jour optimiste (UI immédiate)
      _notifications.removeWhere((n) => n.id == event.notificationId);
      await _saveCachedNotifications();

      emit(
        NotificationActionSuccess(
          message: 'Notification supprimée',
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ),
      );

      // Appel API en arrière-plan
      try {
        await _notificationService.deleteNotification(event.notificationId);
        deboger('✅ Notification ${event.notificationId} supprimée (API)');
      } catch (apiError) {
        // Rollback en cas d'erreur API
        deboger('❌ Erreur API deleteNotification, rollback: $apiError');
        _notifications.insert(deletedIndex, deletedNotification);
        await _saveCachedNotifications();

        emit(
          NotificationError(
            message: 'Erreur lors de la suppression: $apiError',
            webSocketState: _currentWebSocketState,
          ),
        );
      }
    } catch (e) {
      deboger('❌ Erreur suppression notification: $e');
      emit(
        NotificationError(
          message: 'Erreur lors de la suppression: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onClearAllNotifications(
    events.ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Sauvegarder l'ancienne liste pour rollback
      final oldNotifications = List<NotificationModel>.from(_notifications);

      // Mise à jour optimiste (UI immédiate)
      _notifications.clear();
      await _saveCachedNotifications();

      emit(
        NotificationActionSuccess(
          message: 'Toutes les notifications supprimées',
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: 0,
        ),
      );

      // Appel API en arrière-plan
      try {
        await _notificationService.clearAllNotifications();
        deboger('✅ Toutes les notifications supprimées (API)');
      } catch (apiError) {
        // Rollback en cas d'erreur API
        deboger('❌ Erreur API clearAllNotifications, rollback: $apiError');
        _notifications = oldNotifications;
        await _saveCachedNotifications();

        emit(
          NotificationError(
            message: 'Erreur lors de la suppression: $apiError',
            webSocketState: _currentWebSocketState,
          ),
        );
      }
    } catch (e) {
      deboger('❌ Erreur suppression toutes notifications: $e');
      emit(
        NotificationError(
          message: 'Erreur lors de la suppression: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onRefreshNotifications(
    events.RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      // Charger depuis l'API
      final apiNotifications =
          await _notificationService.getUserNotifications();
      _notifications = apiNotifications.reversed.toList();
      await _saveCachedNotifications();

      emit(
        NotificationLoaded(
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ),
      );

      deboger(
        '✅ ${apiNotifications.length} notifications rechargées depuis l\'API',
      );
    } catch (e) {
      deboger('❌ Erreur refresh notifications: $e');

      // Fallback sur le cache local en cas d'erreur
      await _loadCachedNotifications();

      emit(
        NotificationError(
          message: 'Erreur lors du rafraîchissement: $e',
          webSocketState: _currentWebSocketState,
        ),
      );
    }
  }

  Future<void> _onConnectWebSocket(
    events.ConnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(
        WebSocketConnecting(
          _currentWebSocketState.copyWith(
            status: WebSocketConnectionStatus.connecting,
          ),
        ),
      );

      await _webSocketService.connect(
        userPhone: event.userPhone,
        authToken: event.authToken,
      );
    } catch (e) {
      deboger('❌ Erreur connexion WebSocket: $e');
      emit(
        WebSocketError(
          webSocketState: _currentWebSocketState,
          errorMessage: 'Erreur de connexion: $e',
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
        ),
      );
    }
  }

  Future<void> _onDisconnectWebSocket(
    events.DisconnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _webSocketService.disconnect();

      emit(
        WebSocketDisconnected(
          webSocketState: _currentWebSocketState,
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
          reason: 'Déconnexion demandée',
        ),
      );
    } catch (e) {
      deboger('❌ Erreur déconnexion WebSocket: $e');
    }
  }

  Future<void> _onReconnectWebSocket(
    events.ReconnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(
        WebSocketConnecting(
          _currentWebSocketState.copyWith(
            status: WebSocketConnectionStatus.reconnecting,
          ),
        ),
      );

      await _webSocketService.reconnect();
    } catch (e) {
      deboger('❌ Erreur reconnexion WebSocket: $e');
      emit(
        WebSocketError(
          webSocketState: _currentWebSocketState,
          errorMessage: 'Erreur de reconnexion: $e',
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
        ),
      );
    }
  }

  Future<void> _onWebSocketStateChanged(
    events.WebSocketStateChanged event,
    Emitter<NotificationState> emit,
  ) async {
    final webSocketState = event.webSocketState as WebSocketState;

    if (webSocketState.isConnected) {
      emit(
        WebSocketConnected(
          webSocketState: webSocketState,
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
        ),
      );
    } else if (webSocketState.hasError) {
      emit(
        WebSocketError(
          webSocketState: webSocketState,
          errorMessage: webSocketState.errorMessage ?? 'Erreur WebSocket',
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
        ),
      );
    } else if (webSocketState.isDisconnected) {
      emit(
        WebSocketDisconnected(
          webSocketState: webSocketState,
          notifications: _notifications,
          unreadCount: _getUnreadCount(),
        ),
      );
    }
  }

  Future<void> _onSendTestNotification(
    events.SendTestNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Créer une notification de test
      final testNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        titre: event.title,
        contenu: event.content,
        event: NotificationEvent.notification,
        lu: false,
        createdAt: DateTime.now(),
      );

      add(events.NotificationReceived(testNotification));
    } catch (e) {
      deboger('❌ Erreur envoi notification test: $e');
    }
  }

  // Méthodes utilitaires
  int _getUnreadCount() {
    return _notifications.where((n) => n.isUnread).length;
  }

  Future<void> _loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _notifications =
            notificationsList
                .map((json) => NotificationModel.fromJson(json))
                .toList();

        deboger('📱 ${_notifications.length} notifications chargées du cache');
      }
    } catch (e) {
      deboger('❌ Erreur chargement cache notifications: $e');
      _notifications = [];
    }
  }

  Future<void> _saveCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        _notifications.map((n) => n.toJson()).toList(),
      );

      await prefs.setString(_notificationsKey, notificationsJson);
      await prefs.setInt(_unreadCountKey, _getUnreadCount());

      deboger('💾 ${_notifications.length} notifications sauvées en cache');
    } catch (e) {
      deboger('❌ Erreur sauvegarde cache notifications: $e');
    }
  }

  // Getters publics
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _getUnreadCount();
  WebSocketState get webSocketState => _currentWebSocketState;
  bool get isWebSocketConnected => _currentWebSocketState.isConnected;

  // ==================== RÉINITIALISATION ====================

  /// Réinitialise le BLoC à son état Initial
  Future<void> _onResetNotificationState(
    events.ResetNotificationState event,
    Emitter<NotificationState> emit,
  ) async {
    deboger(['[NotificationBloc] Réinitialisation à l\'état Initial']);
    _notifications = [];
    await _saveCachedNotifications(); // Sauvegarde la liste vide en cache
    emit(const NotificationInitial());
  }

  // ==================== FCM HANDLERS ====================

  /// Initialise FCM et s'abonne aux streams
  Future<void> _onInitializeFCM(
    events.InitializeFCM event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Initialiser le service FCM
      await _fcmService.initialize();

      // S'abonner au stream de notifications FCM
      _fcmNotificationSubscription?.cancel();
      _fcmNotificationSubscription = _fcmService.notificationStream.listen(
        (notification) {
          add(events.NotificationReceived(notification));
        },
        onError: (error) {
          deboger('❌ Erreur stream FCM notifications: $error');
        },
      );

      // S'abonner au stream de token FCM
      _fcmTokenSubscription?.cancel();
      _fcmTokenSubscription = _fcmService.tokenStream.listen(
        (token) {
          add(events.FCMTokenReceived(token));
        },
        onError: (error) {
          deboger('❌ Erreur stream FCM token: $error');
        },
      );

      // Si un token existe déjà, l'envoyer
      final currentToken = _fcmService.fcmToken;
      if (currentToken != null) {
        add(events.FCMTokenReceived(currentToken));
      }

      deboger('✅ FCM initialisé avec succès');
    } catch (e) {
      deboger('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Gère la réception d'un nouveau token FCM
  Future<void> _onFCMTokenReceived(
    events.FCMTokenReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Envoyer le token au backend
      await _notificationService.registerFCMToken(event.token);
      deboger('✅ Token FCM envoyé au serveur: ${event.token.substring(0, 20)}...');
    } catch (e) {
      deboger('❌ Erreur envoi token FCM au serveur: $e');
    }
  }

  /// Supprime le token FCM (lors du logout)
  Future<void> _onDeleteFCMToken(
    events.DeleteFCMToken event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Supprimer le token du backend
      await _notificationService.unregisterFCMToken();

      // Supprimer le token localement
      await _fcmService.deleteToken();

      deboger('✅ Token FCM supprimé');
    } catch (e) {
      deboger('❌ Erreur suppression token FCM: $e');
    }
  }

  @override
  Future<void> close() {
    _webSocketStateSubscription?.cancel();
    _notificationSubscription?.cancel();
    _fcmNotificationSubscription?.cancel();
    _fcmTokenSubscription?.cancel();
    return super.close();
  }
}
