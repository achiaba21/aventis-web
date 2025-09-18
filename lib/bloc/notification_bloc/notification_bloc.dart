import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_flutter/bloc/notification_bloc/notification_event.dart' as events;
import 'package:web_flutter/bloc/notification_bloc/notification_state.dart';
import 'package:web_flutter/model/notification/notification.dart';
import 'package:web_flutter/model/websocket/websocket_state.dart';
import 'package:web_flutter/service/websocket/websocket_service.dart';
import 'package:web_flutter/util/function.dart';
import 'dart:convert';

class NotificationBloc extends Bloc<events.NotificationEvent, NotificationState> {
  final WebSocketService _webSocketService = WebSocketService.instance;

  // Subscriptions pour les streams WebSocket
  StreamSubscription<WebSocketState>? _webSocketStateSubscription;
  StreamSubscription<NotificationModel>? _notificationSubscription;

  // Cache local des notifications
  List<NotificationModel> _notifications = [];
  WebSocketState _currentWebSocketState = const WebSocketState();

  // Cl� pour le stockage local
  static const String _notificationsKey = 'cached_notifications';
  static const String _unreadCountKey = 'unread_notifications_count';

  NotificationBloc() : super(const NotificationInitial()) {
    // Enregistrement des handlers d'�v�nements
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

    // Initialisation des streams WebSocket
    _initializeWebSocketStreams();
  }

  void _initializeWebSocketStreams() {
    // �coute des changements d'�tat WebSocket
    _webSocketStateSubscription = _webSocketService.stateStream.listen(
      (webSocketState) {
        _currentWebSocketState = webSocketState;
        add(events.WebSocketStateChanged(webSocketState));
      },
      onError: (error) {
        deboger('Erreur stream WebSocket state: $error');
      },
    );

    // �coute des notifications re�ues
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

      emit(NotificationLoaded(
        notifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: _getUnreadCount(),
      ));

      deboger(' Notifications initialis�es avec ${_notifications.length} notifications');

    } catch (e) {
      deboger('L Erreur initialisation notifications: $e');
      emit(NotificationError(
        message: 'Erreur lors de l\'initialisation: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onLoadNotifications(
    events.LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _loadCachedNotifications();

      emit(NotificationLoaded(
        notifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: _getUnreadCount(),
      ));

    } catch (e) {
      deboger('L Erreur chargement notifications: $e');
      emit(NotificationError(
        message: 'Erreur lors du chargement: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onNotificationReceived(
    events.NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Ajouter en t�te de liste (plus r�cent en premier)
      _notifications.insert(0, event.notification);

      // Limiter le nombre de notifications en cache
      if (_notifications.length > 100) {
        _notifications = _notifications.take(100).toList();
      }

      // Sauvegarder en cache local
      await _saveCachedNotifications();

      emit(NotificationReceivedState(
        notification: event.notification,
        allNotifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: _getUnreadCount(),
      ));

      deboger('= Nouvelle notification re�ue: ${event.notification.displayTitle}');

    } catch (e) {
      deboger('L Erreur traitement notification re�ue: $e');
    }
  }

  Future<void> _onMarkNotificationAsRead(
    events.MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == event.notificationId);

      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        await _saveCachedNotifications();

        emit(NotificationActionSuccess(
          message: 'Notification marqu�e comme lue',
          notifications: _notifications,
          webSocketState: _currentWebSocketState,
          unreadCount: _getUnreadCount(),
        ));

        deboger(' Notification ${event.notificationId} marqu�e comme lue');
      }

    } catch (e) {
      deboger('L Erreur marquage notification lue: $e');
      emit(NotificationError(
        message: 'Erreur lors du marquage: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    events.MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      await _saveCachedNotifications();

      emit(NotificationActionSuccess(
        message: 'Toutes les notifications marqu�es comme lues',
        notifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: 0,
      ));

      deboger(' Toutes les notifications marqu�es comme lues');

    } catch (e) {
      deboger('L Erreur marquage toutes notifications lues: $e');
      emit(NotificationError(
        message: 'Erreur lors du marquage: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onDeleteNotification(
    events.DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _notifications.removeWhere((n) => n.id == event.notificationId);
      await _saveCachedNotifications();

      emit(NotificationActionSuccess(
        message: 'Notification supprim�e',
        notifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: _getUnreadCount(),
      ));

      deboger(' Notification ${event.notificationId} supprim�e');

    } catch (e) {
      deboger('L Erreur suppression notification: $e');
      emit(NotificationError(
        message: 'Erreur lors de la suppression: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onClearAllNotifications(
    events.ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _notifications.clear();
      await _saveCachedNotifications();

      emit(NotificationActionSuccess(
        message: 'Toutes les notifications supprim�es',
        notifications: _notifications,
        webSocketState: _currentWebSocketState,
        unreadCount: 0,
      ));

      deboger(' Toutes les notifications supprim�es');

    } catch (e) {
      deboger('L Erreur suppression toutes notifications: $e');
      emit(NotificationError(
        message: 'Erreur lors de la suppression: $e',
        webSocketState: _currentWebSocketState,
      ));
    }
  }

  Future<void> _onRefreshNotifications(
    events.RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    add(const events.LoadNotifications());
  }

  Future<void> _onConnectWebSocket(
    events.ConnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(WebSocketConnecting(_currentWebSocketState.copyWith(
        status: WebSocketConnectionStatus.connecting,
      )));

      await _webSocketService.connect(
        userPhone: event.userPhone,
        authToken: event.authToken,
      );

    } catch (e) {
      deboger('L Erreur connexion WebSocket: $e');
      emit(WebSocketError(
        webSocketState: _currentWebSocketState,
        errorMessage: 'Erreur de connexion: $e',
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
      ));
    }
  }

  Future<void> _onDisconnectWebSocket(
    events.DisconnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _webSocketService.disconnect();

      emit(WebSocketDisconnected(
        webSocketState: _currentWebSocketState,
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
        reason: 'D�connexion demand�e',
      ));

    } catch (e) {
      deboger('L Erreur d�connexion WebSocket: $e');
    }
  }

  Future<void> _onReconnectWebSocket(
    events.ReconnectWebSocket event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(WebSocketConnecting(_currentWebSocketState.copyWith(
        status: WebSocketConnectionStatus.reconnecting,
      )));

      await _webSocketService.reconnect();

    } catch (e) {
      deboger('L Erreur reconnexion WebSocket: $e');
      emit(WebSocketError(
        webSocketState: _currentWebSocketState,
        errorMessage: 'Erreur de reconnexion: $e',
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
      ));
    }
  }

  Future<void> _onWebSocketStateChanged(
    events.WebSocketStateChanged event,
    Emitter<NotificationState> emit,
  ) async {
    final webSocketState = event.webSocketState as WebSocketState;

    if (webSocketState.isConnected) {
      emit(WebSocketConnected(
        webSocketState: webSocketState,
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
      ));
    } else if (webSocketState.hasError) {
      emit(WebSocketError(
        webSocketState: webSocketState,
        errorMessage: webSocketState.errorMessage ?? 'Erreur WebSocket',
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
      ));
    } else if (webSocketState.isDisconnected) {
      emit(WebSocketDisconnected(
        webSocketState: webSocketState,
        notifications: _notifications,
        unreadCount: _getUnreadCount(),
      ));
    }
  }

  Future<void> _onSendTestNotification(
    events.SendTestNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Cr�er une notification de test
      final testNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        titre: event.title,
        contenu: event.content,
        event: NotificationEvent.notification,
        status: NotificationStatus.enAttente,
        createdAt: DateTime.now(),
      );

      add(events.NotificationReceived(testNotification));

    } catch (e) {
      deboger('L Erreur envoi notification test: $e');
    }
  }

  // M�thodes utilitaires
  int _getUnreadCount() {
    return _notifications.where((n) => n.isUnread).length;
  }

  Future<void> _loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        _notifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        deboger('=� ${_notifications.length} notifications charg�es du cache');
      }
    } catch (e) {
      deboger('L Erreur chargement cache notifications: $e');
      _notifications = [];
    }
  }

  Future<void> _saveCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(_notifications.map((n) => n.toJson()).toList());

      await prefs.setString(_notificationsKey, notificationsJson);
      await prefs.setInt(_unreadCountKey, _getUnreadCount());

      deboger('=� ${_notifications.length} notifications sauv�es en cache');
    } catch (e) {
      deboger('L Erreur sauvegarde cache notifications: $e');
    }
  }

  // Getters publics
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _getUnreadCount();
  WebSocketState get webSocketState => _currentWebSocketState;
  bool get isWebSocketConnected => _currentWebSocketState.isConnected;

  @override
  Future<void> close() {
    _webSocketStateSubscription?.cancel();
    _notificationSubscription?.cancel();
    return super.close();
  }
}