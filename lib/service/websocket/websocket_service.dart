import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/util/function.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  WebSocketService._internal();

  StompClient? _stompClient;
  Timer? _reconnectTimer;

  // Streams pour communiquer avec les blocs
  final StreamController<WebSocketState> _stateController =
      StreamController<WebSocketState>.broadcast();
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<RealtimeAction> _actionController =
      StreamController<RealtimeAction>.broadcast();

  // État actuel
  WebSocketState _currentState = const WebSocketState();
  String? _userPhone;
  String? _authToken;

  // Configuration de reconnexion
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  // Getters publics
  Stream<WebSocketState> get stateStream => _stateController.stream;
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;
  Stream<RealtimeAction> get actionStream => _actionController.stream;
  WebSocketState get currentState => _currentState;
  bool get isConnected => _currentState.isConnected;

  // Initialisation et connexion
  Future<void> connect({required String userPhone, String? authToken}) async {
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
      _updateState(
        _currentState.copyWith(
          status: WebSocketConnectionStatus.connecting,
          errorMessage: null,
        ),
      );

      // Construction de l'URL WebSocket
      final wsUrl = _buildWebSocketUrl();
      deboger('Connexion WebSocket vers: $wsUrl');

      // Configuration du client STOMP WebSocket natif
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onStompConnected,
          onWebSocketError:
              (dynamic error) => _handleConnectionError(error.toString()),
          onStompError:
              (StompFrame frame) =>
                  _handleConnectionError('STOMP Error: ${frame.body}'),
          onDisconnect: _onStompDisconnected,
          beforeConnect: () async {
            deboger('🔄 Préparation de la connexion WebSocket/STOMP...');
          },
          onWebSocketDone: () => _handleDisconnection(),
          stompConnectHeaders: {
            'telephone': _userPhone ?? '',
            if (_authToken != null) 'authorization': 'Bearer $_authToken',
          },
          connectionTimeout: const Duration(seconds: 10),
        ),
      );

      // Activation du client
      _stompClient!.activate();
    } catch (e) {
      deboger('❌ Erreur connexion WebSocket: $e');
      _handleConnectionError(e.toString());
    }
  }

  String _buildWebSocketUrl() {
    return '$wsDomain/ws/websocket';
  }

  void _onStompConnected(StompFrame frame) {
    // SEC-04 : pas de headers de frame (jeton) ni de téléphone dans les logs
    deboger([
      '═══════════════════════════════════════════',
      '✅ WEBSOCKET/STOMP CONNECTÉ',
      '═══════════════════════════════════════════',
      'User phone pour abonnement: ${_userPhone != null ? 'présent' : 'absent'}',
    ]);

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.connected,
        lastConnectedAt: DateTime.now(),
        reconnectAttempts: 0,
        isAuthenticated: true,
      ),
    );

    // Abonnements après connexion
    _subscribeToPersonalNotifications();
    _subscribeToGlobalActions();
    _subscribeToUserUpdates();
  }

  void _onStompDisconnected(StompFrame frame) {
    deboger('🔌 WebSocket/STOMP déconnecté: ${frame.body}');
    _handleDisconnection();
  }

  void _subscribeToPersonalNotifications() {
    if (_userPhone == null || _stompClient == null) return;

    // Avec convertAndSendToUser côté serveur, le client doit s'abonner à /user/queue/...
    // Spring route automatiquement vers le bon utilisateur basé sur le Principal de la session
    const destination = '/user/queue/notifications';

    // SEC-04 : pas de téléphone dans les logs
    deboger([
      '═══════════════════════════════════════════',
      '📱 ABONNEMENT NOTIFICATIONS',
      '═══════════════════════════════════════════',
      'Destination: $destination',
    ]);

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        deboger('📥 Frame reçue sur $destination');
        _handleNotificationMessage(frame);
      },
    );

    deboger('✅ Abonnement notifications actif');
  }

  void _subscribeToGlobalActions() {
    if (_stompClient == null) return;

    const destination = '/topic/actions';

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        _handleActionMessage(frame);
      },
    );

    deboger('🌍 Abonné aux actions globales: $destination');
  }

  /// Canal ciblé par-utilisateur (NOUVEAU) : synchro temps réel des entités
  /// (appartement / document / partenariat / réservation). Spring route via le
  /// Principal de session, comme `/user/queue/notifications`. Le parsing
  /// réutilise `_handleActionMessage` → `RealtimeAction.fromJson` (qui gère
  /// l'enveloppe `entityType`/`action`).
  void _subscribeToUserUpdates() {
    if (_stompClient == null) return;

    const destination = '/user/queue/updates';

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        _handleActionMessage(frame);
      },
    );

    deboger('🔔 Abonné aux updates ciblées: $destination');
  }

  void _handleNotificationMessage(StompFrame frame) {
    // SEC-04 : pas de headers ni de body brut (contenu personnel) dans les logs
    deboger([
      '═══════════════════════════════════════════',
      '🔔 MESSAGE NOTIFICATION REÇU',
      '═══════════════════════════════════════════',
    ]);

    try {
      if (frame.body == null || frame.body!.isEmpty) {
        deboger('⚠️ Body vide ou null - message ignoré');
        return;
      }

      final jsonData = jsonDecode(frame.body!);

      final notification = NotificationModel.fromJson(jsonData);
      deboger([
        '✅ Notification parsée avec succès:',
        '   - ID: ${notification.id}',
        '   - Titre: ${notification.displayTitle}',
        '   - Event: ${notification.event}',
        '   - Lu: ${notification.lu}',
      ]);

      _notificationController.add(notification);
      deboger('📤 Notification émise sur le stream');
    } catch (e, stackTrace) {
      deboger([
        '❌ Erreur parsing notification:',
        '   - Erreur: $e',
        '   - Stack: $stackTrace',
      ]);
    }
  }

  void _handleActionMessage(StompFrame frame) {
    // SEC-04 : pas de headers ni de body brut (contenu personnel) dans les logs
    deboger([
      '═══════════════════════════════════════════',
      '⚡ MESSAGE ACTION REÇU',
      '═══════════════════════════════════════════',
    ]);

    try {
      if (frame.body == null || frame.body!.isEmpty) {
        deboger('⚠️ Body vide ou null - action ignorée');
        return;
      }

      final jsonData = jsonDecode(frame.body!);

      final action = RealtimeAction.fromJson(jsonData);
      deboger([
        '✅ Action parsée avec succès:',
        '   - Type: ${action.type}',
        '   - Timestamp: ${action.timestamp}',
      ]);

      _actionController.add(action);
      deboger('📤 Action émise sur le stream');
    } catch (e, stackTrace) {
      deboger([
        '❌ Erreur parsing action:',
        '   - Erreur: $e',
        '   - Stack: $stackTrace',
      ]);
    }
  }

  void _handleConnectionError(String error) {
    deboger('❌ Erreur WebSocket: $error');

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.error,
        errorMessage: error,
        lastDisconnectedAt: DateTime.now(),
      ),
    );

    _scheduleReconnect();
  }

  void _handleDisconnection() {
    deboger('🔌 WebSocket déconnecté');

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.disconnected,
        lastDisconnectedAt: DateTime.now(),
        isAuthenticated: false,
      ),
    );

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_currentState.reconnectAttempts >= _maxReconnectAttempts) {
      deboger('❌ Nombre maximum de tentatives de reconnexion atteint');
      return;
    }

    _reconnectTimer?.cancel();

    final delay = _calculateReconnectDelay(_currentState.reconnectAttempts);
    deboger(
      '🔄 Reconnexion programmée dans ${delay.inSeconds}s (tentative ${_currentState.reconnectAttempts + 1})',
    );

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.reconnecting,
        reconnectAttempts: _currentState.reconnectAttempts + 1,
      ),
    );

    _reconnectTimer = Timer(delay, () {
      if (_userPhone != null) {
        _connect();
      }
    });
  }

  Duration _calculateReconnectDelay(int attempts) {
    final delay =
        _initialReconnectDelay * (1 << attempts); // Exponential backoff
    return delay < _maxReconnectDelay ? delay : _maxReconnectDelay;
  }

  void _updateState(WebSocketState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  // Méthodes publiques
  Future<void> disconnect() async {
    deboger('🔌 Déconnexion WebSocket/STOMP demandée');

    _reconnectTimer?.cancel();

    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.disconnected,
        lastDisconnectedAt: DateTime.now(),
        isAuthenticated: false,
        reconnectAttempts: 0,
      ),
    );
  }

  Future<void> reconnect() async {
    await disconnect();
    if (_userPhone != null) {
      await connect(userPhone: _userPhone!, authToken: _authToken);
    }
  }

  /// Relance une tentative de connexion UNIQUEMENT si le socket a réellement
  /// abandonné (aucune tentative en cours, aucun timer de reconnexion actif).
  ///
  /// Utilisé par `ConnectivityService` pour « réveiller » le socket après que
  /// les tentatives internes (backoff) aient été épuisées. Conçu pour ne JAMAIS
  /// créer de connexion parallèle :
  /// - no-op si déjà connecté / en cours de connexion / en reconnexion ;
  /// - no-op si le socket a déjà un timer de reconnexion programmé ;
  /// - sinon, désactive proprement l'ancien client avant d'en relancer un.
  void reconnectNow() {
    if (_currentState.isConnected ||
        _currentState.isConnecting ||
        _currentState.isReconnecting) {
      return;
    }
    // Le socket va déjà retenter tout seul → ne pas interférer (anti-churn).
    if (_reconnectTimer?.isActive ?? false) return;
    if (_userPhone == null) return;

    // Fermer proprement l'éventuel client mort avant d'en recréer un, sinon
    // on se retrouve avec deux connexions STOMP concurrentes.
    _stompClient?.deactivate();
    _stompClient = null;

    _updateState(_currentState.copyWith(reconnectAttempts: 0));
    deboger('🔄 reconnectNow() — relance de la connexion WebSocket');
    _connect();
  }

  void sendMessage(String destination, Map<String, dynamic> body) {
    if (!_currentState.isConnected || _stompClient == null) {
      deboger('❌ Impossible d\'envoyer le message: WebSocket non connecté');
      return;
    }

    try {
      _stompClient!.send(
        destination: destination,
        body: jsonEncode(body),
        headers: {'content-type': 'application/json'},
      );

      deboger('📤 Message envoyé vers $destination');
    } catch (e) {
      deboger('❌ Erreur envoi message: $e');
    }
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _notificationController.close();
    _actionController.close();
    _reconnectTimer?.cancel();
  }
}
