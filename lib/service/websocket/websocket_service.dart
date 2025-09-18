import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/notification/notification.dart';
import 'package:web_flutter/model/websocket/websocket_state.dart';
import 'package:web_flutter/util/function.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  WebSocketService._internal();

  WebSocket? _webSocket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // Streams pour communiquer avec les blocs
  final StreamController<WebSocketState> _stateController = StreamController<WebSocketState>.broadcast();
  final StreamController<NotificationModel> _notificationController = StreamController<NotificationModel>.broadcast();
  final StreamController<RealtimeAction> _actionController = StreamController<RealtimeAction>.broadcast();

  // État actuel
  WebSocketState _currentState = const WebSocketState();
  String? _userPhone;
  String? _authToken;

  // Configuration de reconnexion
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Getters publics
  Stream<WebSocketState> get stateStream => _stateController.stream;
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
  Stream<RealtimeAction> get actionStream => _actionController.stream;
  WebSocketState get currentState => _currentState;
  bool get isConnected => _currentState.isConnected;

  // Initialisation et connexion
  Future<void> connect({
    required String userPhone,
    String? authToken,
  }) async {
    _userPhone = userPhone;
    _authToken = authToken;

    if (_currentState.isConnected || _currentState.isConnecting) {
      deboger('WebSocket déjà connecté ou en cours de connexion');
      return;
    }

    await _connect();
  }

  Future<void> _connect() async {
    try {
      _updateState(_currentState.copyWith(
        status: WebSocketConnectionStatus.connecting,
        errorMessage: null,
      ));

      // Construction de l'URL WebSocket
      final wsUrl = _buildWebSocketUrl();
      deboger('Connexion WebSocket vers: $wsUrl');

      // Connexion WebSocket brute (simulation STOMP)
      _webSocket = await WebSocket.connect(wsUrl);

      // Configuration des listeners
      _setupWebSocketListeners();

      // Envoi du message de connexion STOMP
      _sendStompConnect();

      // Démarrage du heartbeat
      _startHeartbeat();

      _updateState(_currentState.copyWith(
        status: WebSocketConnectionStatus.connected,
        lastConnectedAt: DateTime.now(),
        reconnectAttempts: 0,
        isAuthenticated: true,
      ));

      deboger('✅ WebSocket connecté avec succès');

    } catch (e) {
      deboger('❌ Erreur connexion WebSocket: $e');
      _handleConnectionError(e.toString());
    }
  }

  String _buildWebSocketUrl() {
    // Conversion HTTP vers WebSocket
    final baseUrl = domain.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    return '$baseUrl/ws/websocket';
  }

  void _setupWebSocketListeners() {
    _webSocket?.listen(
      (data) => _handleMessage(data),
      onError: (error) => _handleConnectionError(error.toString()),
      onDone: () => _handleDisconnection(),
    );
  }

  void _sendStompConnect() {
    final connectFrame = _buildStompFrame('CONNECT', headers: {
      'accept-version': '1.2',
      'heart-beat': '0,0',
      'telephone': _userPhone ?? '',
      if (_authToken != null) 'authorization': 'Bearer $_authToken',
    });

    _webSocket?.add(connectFrame);

    // Abonnement aux notifications personnalisées
    _subscribeToPersonalNotifications();

    // Abonnement aux actions globales
    _subscribeToGlobalActions();
  }

  void _subscribeToPersonalNotifications() {
    if (_userPhone == null) return;

    final subscribeFrame = _buildStompFrame('SUBSCRIBE', headers: {
      'id': 'sub-notifications',
      'destination': '/user/$_userPhone/queue/notifications',
    });

    _webSocket?.add(subscribeFrame);
    deboger('📱 Abonné aux notifications: /user/$_userPhone/queue/notifications');
  }

  void _subscribeToGlobalActions() {
    final subscribeFrame = _buildStompFrame('SUBSCRIBE', headers: {
      'id': 'sub-actions',
      'destination': '/topic/actions',
    });

    _webSocket?.add(subscribeFrame);
    deboger('🌍 Abonné aux actions globales: /topic/actions');
  }

  String _buildStompFrame(String command, {Map<String, String>? headers, String? body}) {
    final buffer = StringBuffer();
    buffer.write(command);
    buffer.write('\n');

    if (headers != null) {
      for (final entry in headers.entries) {
        buffer.write('${entry.key}:${entry.value}\n');
      }
    }

    buffer.write('\n');
    if (body != null) {
      buffer.write(body);
    }
    buffer.write('\x00'); // NULL terminator pour STOMP

    return buffer.toString();
  }

  void _handleMessage(dynamic data) {
    try {
      final message = data.toString();
      deboger('📨 Message WebSocket reçu: ${message.length > 200 ? "${message.substring(0, 200)}..." : message}');

      // Parse du message STOMP
      final stompMessage = _parseStompMessage(message);

      if (stompMessage['command'] == 'CONNECTED') {
        deboger('✅ STOMP connecté avec succès');
        return;
      }

      if (stompMessage['command'] == 'MESSAGE') {
        _handleStompMessage(stompMessage);
      }

    } catch (e) {
      deboger('❌ Erreur parsing message WebSocket: $e');
    }
  }

  Map<String, dynamic> _parseStompMessage(String message) {
    final lines = message.split('\n');
    final command = lines.isNotEmpty ? lines[0] : '';

    final headers = <String, String>{};
    String? body;

    int i = 1;
    // Parse headers
    while (i < lines.length && lines[i].isNotEmpty) {
      final headerLine = lines[i];
      final colonIndex = headerLine.indexOf(':');
      if (colonIndex > 0) {
        final key = headerLine.substring(0, colonIndex);
        final value = headerLine.substring(colonIndex + 1);
        headers[key] = value;
      }
      i++;
    }

    // Skip empty line
    i++;

    // Parse body
    if (i < lines.length) {
      body = lines.sublist(i).join('\n').replaceAll('\x00', '');
    }

    return {
      'command': command,
      'headers': headers,
      'body': body,
    };
  }

  void _handleStompMessage(Map<String, dynamic> stompMessage) {
    final destination = stompMessage['headers']['destination'] as String?;
    final body = stompMessage['body'] as String?;

    if (destination == null || body == null || body.isEmpty) {
      return;
    }

    try {
      final jsonData = jsonDecode(body);

      if (destination.contains('/queue/notifications')) {
        // Notification personnalisée
        final notification = NotificationModel.fromJson(jsonData);
        _notificationController.add(notification);
        deboger('🔔 Notification reçue: ${notification.displayTitle}');

      } else if (destination.contains('/topic/actions')) {
        // Action temps réel
        final action = RealtimeAction.fromJson(jsonData);
        _actionController.add(action);
        deboger('⚡ Action temps réel reçue: ${action.type}');
      }

    } catch (e) {
      deboger('❌ Erreur parsing JSON: $e');
    }
  }

  void _handleConnectionError(String error) {
    deboger('❌ Erreur WebSocket: $error');

    _updateState(_currentState.copyWith(
      status: WebSocketConnectionStatus.error,
      errorMessage: error,
      lastDisconnectedAt: DateTime.now(),
    ));

    _scheduleReconnect();
  }

  void _handleDisconnection() {
    deboger('🔌 WebSocket déconnecté');

    _updateState(_currentState.copyWith(
      status: WebSocketConnectionStatus.disconnected,
      lastDisconnectedAt: DateTime.now(),
      isAuthenticated: false,
    ));

    _cleanup();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_currentState.reconnectAttempts >= _maxReconnectAttempts) {
      deboger('❌ Nombre maximum de tentatives de reconnexion atteint');
      return;
    }

    _reconnectTimer?.cancel();

    final delay = _calculateReconnectDelay(_currentState.reconnectAttempts);
    deboger('🔄 Reconnexion programmée dans ${delay.inSeconds}s (tentative ${_currentState.reconnectAttempts + 1})');

    _updateState(_currentState.copyWith(
      status: WebSocketConnectionStatus.reconnecting,
      reconnectAttempts: _currentState.reconnectAttempts + 1,
    ));

    _reconnectTimer = Timer(delay, () {
      if (_userPhone != null) {
        _connect();
      }
    });
  }

  Duration _calculateReconnectDelay(int attempts) {
    final delay = _initialReconnectDelay * (1 << attempts); // Exponential backoff
    return delay < _maxReconnectDelay ? delay : _maxReconnectDelay;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_currentState.isConnected) {
        _sendHeartbeat();
      }
    });
  }

  void _sendHeartbeat() {
    try {
      final heartbeatFrame = _buildStompFrame('PING');
      _webSocket?.add(heartbeatFrame);
      deboger('💓 Heartbeat envoyé');
    } catch (e) {
      deboger('❌ Erreur envoi heartbeat: $e');
    }
  }

  void _updateState(WebSocketState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  // Méthodes publiques
  Future<void> disconnect() async {
    deboger('🔌 Déconnexion WebSocket demandée');

    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    if (_webSocket != null) {
      final disconnectFrame = _buildStompFrame('DISCONNECT');
      _webSocket?.add(disconnectFrame);
      await _webSocket?.close();
    }

    _cleanup();

    _updateState(_currentState.copyWith(
      status: WebSocketConnectionStatus.disconnected,
      lastDisconnectedAt: DateTime.now(),
      isAuthenticated: false,
      reconnectAttempts: 0,
    ));
  }

  Future<void> reconnect() async {
    await disconnect();
    if (_userPhone != null) {
      await connect(userPhone: _userPhone!, authToken: _authToken);
    }
  }

  void sendMessage(String destination, Map<String, dynamic> body) {
    if (!_currentState.isConnected) {
      deboger('❌ Impossible d\'envoyer le message: WebSocket non connecté');
      return;
    }

    try {
      final sendFrame = _buildStompFrame('SEND',
        headers: {
          'destination': destination,
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _webSocket?.add(sendFrame);
      deboger('📤 Message envoyé vers $destination');
    } catch (e) {
      deboger('❌ Erreur envoi message: $e');
    }
  }

  void _cleanup() {
    _webSocket = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _notificationController.close();
    _actionController.close();
    _reconnectTimer?.cancel();
  }
}