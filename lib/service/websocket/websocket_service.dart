import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/auth/token_refresh_coordinator.dart';
import 'package:asfar/service/storage/secure_storage_service.dart';
import 'package:asfar/screen/splash_screen.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/main.dart';

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

  /// Un refresh est en cours suite à un 401 WS : ne pas relancer de connexion
  /// en parallèle (le coordinateur dédoublonne déjà l'appel réseau).
  bool _authRefreshing = false;

  /// Le refresh a échoué (session morte) : on arrête définitivement les
  /// reconnexions jusqu'au prochain `connect()` (nouveau login).
  bool _authFailed = false;

  /// Cycle de reconnexion réseau épuisé (5 tentatives) : on attend le réveil
  /// par `ConnectivityService`. Évite de re-planifier / re-loguer sur le double
  /// déclenchement `onWebSocketError` + `onWebSocketDone` d'un même échec.
  bool _reconnectExhausted = false;

  /// Abonnements aux topics ressource (`/topic/{type}/{id}`) demandés par les
  /// écrans de détail : destination → callback. Conservés pour ré-abonnement
  /// automatique après chaque reconnexion (les souscriptions STOMP meurent avec
  /// le socket).
  final Map<String, void Function(StompFrame)> _topicCallbacks = {};

  /// Handles STOMP actifs des topics ci-dessus (destination → unsubscribe).
  final Map<String, StompUnsubscribe> _topicUnsubs = {};

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
    // Nouveau login / nouvelle session : on réarme l'auth et la reconnexion.
    _authFailed = false;
    _authRefreshing = false;
    _reconnectExhausted = false;

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

      // JWT requis par le backend depuis la fiche sécurité 05 (12/06) : tout
      // CONNECT sans « Authorization: Bearer <jwt> » est rejeté (frame ERROR au
      // corps vide → « STOMP Error: null »). On lit le jeton depuis le stockage
      // sécurisé (même source que Dio), avec repli sur celui fourni à connect().
      // Casse exacte « Authorization » : le backend lit
      // accessor.getFirstNativeHeader("Authorization").
      final token = SecureStorageService.instance.cachedToken ?? _authToken;
      final authHeaders = <String, String>{
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

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
          // Frame STOMP CONNECT (lue par WebSocketAuthInterceptor.preSend).
          stompConnectHeaders: {
            'telephone': _userPhone ?? '',
            ...authHeaders,
          },
          // Handshake WebSocket (validé aussi côté serveur sur mobile).
          webSocketConnectHeaders: authHeaders,
          connectionTimeout: const Duration(seconds: 10),
          // Reconnexion 100 % pilotée par nous (backoff + revive) : on désactive
          // l'auto-reconnect interne de stomp_dart_client (5 s par défaut) qui
          // créait des sockets concurrents → rafale de « Connection refused ».
          reconnectDelay: Duration.zero,
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

    _reconnectExhausted = false;
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

    // Ré-abonner les topics ressource actifs (écrans de détail) : leurs
    // souscriptions sont mortes avec l'ancien socket.
    _topicUnsubs.clear();
    for (final destination in _topicCallbacks.keys.toList()) {
      _activateTopic(destination);
    }
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

  // ==================== Topics ressource (écrans de détail) ====================

  /// Abonne à un topic ressource (`/topic/{type}/{id}`) — utilisé par les écrans
  /// de détail via `RealtimeResourceController`. Idempotent ; ré-abonné
  /// automatiquement après reconnexion. Un refus de souscription côté serveur
  /// est ignoré silencieusement (aucun frame n'est livré).
  void subscribeTopic(String destination, void Function(StompFrame) onFrame) {
    _topicCallbacks[destination] = onFrame;
    _activateTopic(destination);
  }

  /// Désabonne d'un topic ressource (à la fermeture de l'écran de détail).
  void unsubscribeTopic(String destination) {
    _topicCallbacks.remove(destination);
    final unsub = _topicUnsubs.remove(destination);
    try {
      unsub?.call();
    } catch (_) {
      // Socket déjà fermé : rien à faire.
    }
  }

  /// Active réellement l'abonnement STOMP si le socket est connecté. Sinon il
  /// reste en attente dans `_topicCallbacks` et sera (ré)abonné au prochain
  /// `_onStompConnected`.
  void _activateTopic(String destination) {
    if (_stompClient == null || !_currentState.isConnected) return;
    if (_topicUnsubs.containsKey(destination)) return; // déjà actif
    final callback = _topicCallbacks[destination];
    if (callback == null) return;
    try {
      _topicUnsubs[destination] = _stompClient!.subscribe(
        destination: destination,
        callback: callback,
      );
      deboger('🔔 Abonné au topic ressource: $destination');
    } catch (e) {
      // Refus de souscription / erreur locale → ignoré (pas de frame livré).
      deboger('⚠️ Abonnement topic ignoré ($destination): $e');
    }
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

    // Un 401 au handshake = access token expiré, PAS une coupure réseau :
    // retenter en boucle est inutile (et inondait les logs). On tente un
    // refresh partagé puis on reconnecte ; si le refresh échoue, logout propre.
    if (error.contains('401')) {
      _handleAuthError();
      return;
    }

    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.error,
        errorMessage: error,
        lastDisconnectedAt: DateTime.now(),
      ),
    );

    _scheduleReconnect();
  }

  /// Gère un 401 WebSocket (access expiré) : refresh single-flight (partagé
  /// avec l'intercepteur Dio) puis reconnexion ; logout + retour login si le
  /// refresh échoue. Idempotent tant qu'un traitement est déjà en cours.
  Future<void> _handleAuthError() async {
    if (_authRefreshing || _authFailed) return;
    _authRefreshing = true;

    // Stopper la boucle de reconnexion le temps du refresh.
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _stompClient = null;

    final refreshed = await TokenRefreshCoordinator.instance.refresh();
    _authRefreshing = false;

    if (refreshed) {
      deboger('🔄 WebSocket : token rafraîchi — reconnexion');
      _reconnectExhausted = false;
      _updateState(_currentState.copyWith(reconnectAttempts: 0));
      _connect();
      return;
    }

    // Refresh impossible : session morte → on arrête tout et on déconnecte
    // (même voie que l'intercepteur Dio 401).
    _authFailed = true;
    deboger('🔒 WebSocket : refresh impossible — déconnexion');
    _updateState(
      _currentState.copyWith(
        status: WebSocketConnectionStatus.disconnected,
        isAuthenticated: false,
        lastDisconnectedAt: DateTime.now(),
      ),
    );

    await AuthManager.instance.logout();
    // navigatorKey global (pas un context de widget démonté) → usage sûr.
    final context = navigatorKey.currentContext;
    if (context != null) {
      // ignore: use_build_context_synchronously
      await pushScreen(context, const SplashScreen());
    }
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
    // Échec d'auth (refresh KO) ou refresh en cours : ne pas programmer de
    // reconnexion réseau — c'est l'auth qui bloque, pas la connectivité.
    if (_authFailed || _authRefreshing) return;

    // `onWebSocketError` ET `onWebSocketDone` se déclenchent tous deux sur un
    // même échec : si une reconnexion est déjà programmée (ou ce cycle déjà
    // épuisé), ne pas re-planifier — sinon 2 tentatives consommées par échec.
    if ((_reconnectTimer?.isActive ?? false) || _reconnectExhausted) return;

    if (_currentState.reconnectAttempts >= _maxReconnectAttempts) {
      _reconnectExhausted = true;
      deboger('❌ Reconnexions épuisées — attente du retour réseau (revive 15s)');
      return;
    }

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
    // Session morte (refresh KO) ou refresh en cours : ne pas ressusciter le
    // socket — sinon boucle de 401 (l'ancien bug du « flot de déconnexions »).
    if (_authFailed || _authRefreshing) return;

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
    _reconnectExhausted = false;
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
