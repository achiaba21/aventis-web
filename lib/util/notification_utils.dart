import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';

/// Fonctions utilitaires pour les notifications
class NotificationUtils {
  /// Récupère le nombre de notifications non lues depuis l'état
  static int getUnreadCount(NotificationState state) {
    if (state is NotificationLoaded) {
      return state.unreadCount;
    } else if (state is NotificationReceivedState) {
      return state.unreadCount;
    } else if (state is NotificationActionSuccess) {
      return state.unreadCount;
    } else if (state is WebSocketConnected ||
               state is WebSocketDisconnected ||
               state is WebSocketError) {
      final wsState = state as dynamic;
      return wsState.unreadCount ?? 0;
    }
    return 0;
  }

  /// Récupère la liste des notifications depuis l'état
  static List<NotificationModel> getNotifications(NotificationState state) {
    if (state is NotificationLoaded) {
      return state.notifications;
    } else if (state is NotificationReceivedState) {
      return state.allNotifications;
    } else if (state is NotificationActionSuccess) {
      return state.notifications;
    } else if (state is WebSocketConnected ||
               state is WebSocketDisconnected ||
               state is WebSocketError) {
      final wsState = state as dynamic;
      return wsState.notifications ?? [];
    }
    return [];
  }

  /// Récupère l'état WebSocket depuis l'état de notification
  static dynamic getWebSocketState(NotificationState state) {
    if (state is NotificationLoaded) {
      return state.webSocketState;
    } else if (state is WebSocketConnected) {
      return state.webSocketState;
    } else if (state is WebSocketDisconnected) {
      return state.webSocketState;
    } else if (state is WebSocketError) {
      return state.webSocketState;
    }
    return null;
  }

  /// Compte le nombre de notifications de type réservation
  static int getReservationCount(List<NotificationModel> notifications) {
    return notifications
        .where((n) => n.event == NotificationEvent.reservation)
        .length;
  }

  /// Compte le nombre de notifications de type message
  static int getMessageCount(List<NotificationModel> notifications) {
    return notifications
        .where((n) => n.event == NotificationEvent.message)
        .length;
  }
}
