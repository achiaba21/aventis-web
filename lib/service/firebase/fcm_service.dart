import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/service/firebase/local_notification_service.dart';

/// Service pour gérer Firebase Cloud Messaging (notifications push)
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  // Stream pour les notifications reçues
  final _notificationController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  // Stream pour les changements de token
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _tokenController.stream;

  // Token FCM actuel
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;

  /// Initialise le service FCM
  Future<void> initialize({Function(String?)? onNotificationTapped}) async {
    if (_isInitialized) return;

    try {
      // 1. Initialiser les notifications locales
      await _localNotificationService.initialize(
        onNotificationTapped: onNotificationTapped,
      );

      // 2. Demander les permissions
      await _requestPermissions();

      // 3. Obtenir le token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        debugPrint('[FCMService] Token FCM: $_fcmToken');
        _tokenController.add(_fcmToken!);
      }

      // 4. Écouter le rafraîchissement du token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[FCMService] Token FCM rafraîchi: $newToken');
        _tokenController.add(newToken);
      });

      // 5. Configurer les handlers de messages
      _setupMessageHandlers();

      // 6. Vérifier si l'app a été ouverte via une notification
      await _checkInitialMessage();

      _isInitialized = true;
      debugPrint('[FCMService] Initialisé avec succès');
    } catch (e) {
      debugPrint('[FCMService] Erreur d\'initialisation: $e');
    }
  }

  /// Demande les permissions de notification
  Future<bool> _requestPermissions() async {
    // Permissions Firebase
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    final bool granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('[FCMService] Permissions: ${settings.authorizationStatus}');

    // Permissions locales (Android 13+)
    if (granted) {
      await _localNotificationService.requestPermissions();
    }

    return granted;
  }

  /// Configure les handlers pour les messages FCM
  void _setupMessageHandlers() {
    // Message reçu quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCMService] Message foreground: ${message.messageId}');
      _handleMessage(message, isBackground: false);
    });

    // App ouverte depuis une notification (background ou terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '[FCMService] App ouverte via notification: ${message.messageId}',
      );
      _handleMessageTap(message);
    });
  }

  /// Vérifie si l'app a été lancée via une notification
  Future<void> _checkInitialMessage() async {
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('[FCMService] Message initial: ${initialMessage.messageId}');
      _handleMessageTap(initialMessage);
    }
  }

  /// Traite un message FCM reçu
  void _handleMessage(RemoteMessage message, {required bool isBackground}) {
    final notification = _parseRemoteMessage(message);

    if (notification != null) {
      // Émettre sur le stream pour le Bloc
      _notificationController.add(notification);

      // Afficher une notification locale si l'app est au premier plan
      if (!isBackground && message.notification != null) {
        _showLocalNotification(message);
      }
    }
  }

  /// Traite le tap sur une notification
  void _handleMessageTap(RemoteMessage message) {
    final notification = _parseRemoteMessage(message);
    if (notification != null) {
      _notificationController.add(notification);
    }
    // Ici on pourrait naviguer vers un écran spécifique
    // basé sur message.data
  }

  /// Convertit un RemoteMessage en NotificationModel
  NotificationModel? _parseRemoteMessage(RemoteMessage message) {
    try {
      final data = message.data;

      // Si le backend envoie la notification complète dans data
      if (data.containsKey('notification')) {
        final notifData = data['notification'];
        final Map<String, dynamic> json =
            notifData is String
                ? jsonDecode(notifData)
                : notifData as Map<String, dynamic>;
        return NotificationModel.fromJson(json);
      }

      // Sinon, construire depuis les données disponibles
      return NotificationModel.fromJson(data);
    } catch (e) {
      debugPrint('[FCMService] Erreur parsing message: $e');
      return null;
    }
  }

  /// Affiche une notification locale pour les messages foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotificationService.showNotification(
      id: message.hashCode,
      title: notification.title ?? 'Notification',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Obtient le token FCM actuel (force refresh si nécessaire)
  Future<String?> getToken({bool forceRefresh = false}) async {
    if (forceRefresh || _fcmToken == null) {
      _fcmToken = await _firebaseMessaging.getToken();
    }
    return _fcmToken;
  }

  /// Supprime le token FCM (à appeler lors du logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('[FCMService] Token supprimé');
    } catch (e) {
      debugPrint('[FCMService] Erreur suppression token: $e');
    }
  }

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('[FCMService] Abonné au topic: $topic');
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('[FCMService] Désabonné du topic: $topic');
  }

  /// Libère les ressources
  void dispose() {
    _notificationController.close();
    _tokenController.close();
    _isInitialized = false;
  }
}
