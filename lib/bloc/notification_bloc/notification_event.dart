import 'package:web_flutter/model/notification/notification.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

class InitializeNotifications extends NotificationEvent {
  final String userPhone;
  final String? authToken;

  const InitializeNotifications({
    required this.userPhone,
    this.authToken,
  });
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class NotificationReceived extends NotificationEvent {
  final NotificationModel notification;

  const NotificationReceived(this.notification);
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  const DeleteNotification(this.notificationId);
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

class ConnectWebSocket extends NotificationEvent {
  final String userPhone;
  final String? authToken;

  const ConnectWebSocket({
    required this.userPhone,
    this.authToken,
  });
}

class DisconnectWebSocket extends NotificationEvent {
  const DisconnectWebSocket();
}

class ReconnectWebSocket extends NotificationEvent {
  const ReconnectWebSocket();
}

class WebSocketStateChanged extends NotificationEvent {
  final dynamic webSocketState;

  const WebSocketStateChanged(this.webSocketState);
}

class SendTestNotification extends NotificationEvent {
  final String title;
  final String content;

  const SendTestNotification({
    required this.title,
    required this.content,
  });
}