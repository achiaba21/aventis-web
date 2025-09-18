import 'package:web_flutter/service/websocket/websocket_service.dart';
// import 'package:web_flutter/service/realtime/realtime_action_handler.dart'; // Pour usage futur
import 'package:web_flutter/util/function.dart';

class WebSocketManager {
  static WebSocketManager? _instance;
  static WebSocketManager get instance {
    _instance ??= WebSocketManager._internal();
    return _instance!;
  }

  WebSocketManager._internal();

  final WebSocketService _webSocketService = WebSocketService.instance;
  bool _isInitialized = false;

  Future<void> initialize({
    required String userPhone,
    String? authToken,
  }) async {
    if (_isInitialized) {
      deboger('WebSocketManager déjà initialisé');
      return;
    }

    try {
      // Connecter le WebSocket
      await _webSocketService.connect(
        userPhone: userPhone,
        authToken: authToken,
      );

      _isInitialized = true;
      deboger('✅ WebSocketManager initialisé pour: $userPhone');

    } catch (e) {
      deboger('❌ Erreur initialisation WebSocketManager: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (!_isInitialized) return;

    try {
      await _webSocketService.disconnect();
      _isInitialized = false;
      deboger('🔌 WebSocketManager déconnecté');
    } catch (e) {
      deboger('❌ Erreur déconnexion WebSocketManager: $e');
    }
  }

  Future<void> reconnect() async {
    try {
      await _webSocketService.reconnect();
      deboger('🔄 WebSocketManager reconnecté');
    } catch (e) {
      deboger('❌ Erreur reconnexion WebSocketManager: $e');
    }
  }

  // Getters pour l'état
  bool get isInitialized => _isInitialized;
  bool get isConnected => _webSocketService.isConnected;

  // Streams pour écouter les événements
  Stream<dynamic> get stateStream => _webSocketService.stateStream;
  Stream<dynamic> get notificationStream => _webSocketService.notificationStream;
  Stream<dynamic> get actionStream => _webSocketService.actionStream;
}