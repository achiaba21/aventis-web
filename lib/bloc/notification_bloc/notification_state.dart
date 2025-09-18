import 'package:web_flutter/model/notification/notification.dart';
import 'package:web_flutter/model/websocket/websocket_state.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final WebSocketState webSocketState;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.webSocketState,
    required this.unreadCount,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    WebSocketState? webSocketState,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      webSocketState: webSocketState ?? this.webSocketState,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => n.isUnread).toList();

  List<NotificationModel> get readNotifications =>
      notifications.where((n) => !n.isUnread).toList();

  List<NotificationModel> get reservationNotifications =>
      notifications.where((n) => n.isReservation).toList();

  List<NotificationModel> get messageNotifications =>
      notifications.where((n) => n.isMessage).toList();

  bool get hasUnreadNotifications => unreadCount > 0;
  bool get isWebSocketConnected => webSocketState.isConnected;
}

class NotificationError extends NotificationState {
  final String message;
  final String? errorType;
  final WebSocketState? webSocketState;

  const NotificationError({
    required this.message,
    this.errorType,
    this.webSocketState,
  });
}

class NotificationActionSuccess extends NotificationState {
  final String message;
  final List<NotificationModel> notifications;
  final WebSocketState webSocketState;
  final int unreadCount;

  const NotificationActionSuccess({
    required this.message,
    required this.notifications,
    required this.webSocketState,
    required this.unreadCount,
  });
}

class NotificationReceivedState extends NotificationState {
  final NotificationModel notification;
  final List<NotificationModel> allNotifications;
  final WebSocketState webSocketState;
  final int unreadCount;

  const NotificationReceivedState({
    required this.notification,
    required this.allNotifications,
    required this.webSocketState,
    required this.unreadCount,
  });
}

class WebSocketConnecting extends NotificationState {
  final WebSocketState webSocketState;

  const WebSocketConnecting(this.webSocketState);
}

class WebSocketConnected extends NotificationState {
  final WebSocketState webSocketState;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const WebSocketConnected({
    required this.webSocketState,
    required this.notifications,
    required this.unreadCount,
  });
}

class WebSocketDisconnected extends NotificationState {
  final WebSocketState webSocketState;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? reason;

  const WebSocketDisconnected({
    required this.webSocketState,
    required this.notifications,
    required this.unreadCount,
    this.reason,
  });
}

class WebSocketError extends NotificationState {
  final WebSocketState webSocketState;
  final String errorMessage;
  final List<NotificationModel> notifications;
  final int unreadCount;

  const WebSocketError({
    required this.webSocketState,
    required this.errorMessage,
    required this.notifications,
    required this.unreadCount,
  });
}