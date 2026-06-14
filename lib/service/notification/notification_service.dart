import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service pour gérer les notifications via l'API REST
///
/// Ce service expose 8 endpoints:
/// - GET /api/user/notifications - Liste toutes les notifications
/// - GET /api/user/notifications/unread - Notifications non lues
/// - GET /api/user/notifications/count - Nombre de notifications non lues
/// - GET /api/user/notifications/{id} - Détail d'une notification
/// - POST /api/user/notifications/{id}/read - Marquer comme lue
/// - POST /api/user/notifications/read-all - Tout marquer comme lu
/// - DELETE /api/user/notifications/{id} - Supprimer une notification
/// - DELETE /api/user/notifications - Supprimer toutes les notifications
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  final DioRequest _dioRequest = DioRequest.instance;

  // === GET ENDPOINTS ===

  /// Récupère toutes les notifications de l'utilisateur
  /// GET /api/user/notifications
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final response = await _dioRequest.get('api/user/notifications');

      if (response.statusCode == 200) {
        // Le backend renvoie {body: [...], message: "..."}
        final List<dynamic> notificationsJson =
            ResponseMapper.tryExtractBodyList(response.data) ?? response.data;
        final notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        deboger('✅ ${notifications.length} notifications récupérées');
        return notifications;
      } else {
        throw Exception('Erreur récupération notifications: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur getUserNotifications: $e');
      rethrow;
    }
  }

  /// Récupère uniquement les notifications non lues
  /// GET /api/user/notifications/unread
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _dioRequest.get('api/user/notifications/unread');

      if (response.statusCode == 200) {
        // Le backend renvoie {body: [...], message: "..."}
        final List<dynamic> notificationsJson =
            ResponseMapper.tryExtractBodyList(response.data) ?? response.data;
        final notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        deboger('✅ ${notifications.length} notifications non lues récupérées');
        return notifications;
      } else {
        throw Exception('Erreur récupération notifications non lues: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur getUnreadNotifications: $e');
      rethrow;
    }
  }

  /// Récupère le nombre de notifications non lues
  /// GET /api/user/notifications/count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioRequest.get('api/user/notifications/count');

      if (response.statusCode == 200) {
        final data = response.data;
        // Le backend peut renvoyer soit {body: count} soit {count: X}
        final count = data['body'] ?? data['count'] ?? 0;

        deboger('✅ Nombre de notifications non lues: $count');
        return count is int ? count : int.tryParse(count.toString()) ?? 0;
      } else {
        throw Exception('Erreur récupération count: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur getUnreadCount: $e');
      rethrow;
    }
  }

  /// Récupère le détail d'une notification par son ID
  /// GET /api/user/notifications/{id}
  Future<NotificationModel> getNotification(int notificationId) async {
    try {
      final response = await _dioRequest.get('api/user/notifications/$notificationId');

      if (response.statusCode == 200) {
        // Le backend renvoie {body: notification, message: "..."}
        final notificationJson =
            ResponseMapper.tryExtractBody(response.data) ?? response.data;
        final notification = NotificationModel.fromJson(notificationJson);

        deboger('✅ Notification $notificationId récupérée');
        return notification;
      } else {
        throw Exception('Erreur récupération notification: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur getNotification: $e');
      rethrow;
    }
  }

  // === POST ENDPOINTS ===

  /// Marque une notification comme lue
  /// POST /api/user/notifications/{id}/read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _dioRequest.post(
        'api/user/notifications/$notificationId/read',
      );

      if (response.statusCode == 200) {
        deboger('✅ Notification $notificationId marquée comme lue');
      } else {
        throw Exception('Erreur markAsRead: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur markAsRead: $e');
      rethrow;
    }
  }

  /// Marque toutes les notifications comme lues
  /// POST /api/user/notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      final response = await _dioRequest.post(
        'api/user/notifications/read-all',
      );

      if (response.statusCode == 200) {
        deboger('✅ Toutes les notifications marquées comme lues');
      } else {
        throw Exception('Erreur markAllAsRead: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur markAllAsRead: $e');
      rethrow;
    }
  }

  // === DELETE ENDPOINTS ===

  /// Supprime une notification spécifique
  /// DELETE /api/user/notifications/{id}
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _dioRequest.delete(
        'api/user/notifications/$notificationId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        deboger('✅ Notification $notificationId supprimée');
      } else {
        throw Exception('Erreur deleteNotification: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur deleteNotification: $e');
      rethrow;
    }
  }

  /// Supprime toutes les notifications de l'utilisateur
  /// DELETE /api/user/notifications
  Future<void> clearAllNotifications() async {
    try {
      final response = await _dioRequest.delete(
        'api/user/notifications',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        deboger('✅ Toutes les notifications supprimées');
      } else {
        throw Exception('Erreur clearAllNotifications: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur clearAllNotifications: $e');
      rethrow;
    }
  }

  // === FCM TOKEN ENDPOINTS ===

  /// Enregistre le token FCM de l'utilisateur pour les notifications push
  /// POST /api/user/fcm-token
  Future<void> registerFCMToken(String token) async {
    try {
      final response = await _dioRequest.post(
        'api/user/fcm-token',
        data: {'token': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        deboger('✅ Token FCM enregistré');
      } else {
        throw Exception('Erreur registerFCMToken: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur registerFCMToken: $e');
      rethrow;
    }
  }

  /// Supprime le token FCM de l'utilisateur (lors de la déconnexion)
  /// DELETE /api/user/fcm-token
  Future<void> unregisterFCMToken() async {
    try {
      final response = await _dioRequest.delete(
        'api/user/fcm-token',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        deboger('✅ Token FCM supprimé du serveur');
      } else {
        throw Exception('Erreur unregisterFCMToken: ${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur unregisterFCMToken: $e');
      rethrow;
    }
  }
}
