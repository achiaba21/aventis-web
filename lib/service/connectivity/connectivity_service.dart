import 'dart:async';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/websocket/websocket_service.dart';
import 'package:asfar/util/function.dart';

/// Source de vérité unique de la connectivité serveur.
///
/// Dérive l'état online/offline du `stateStream` du [WebSocketService] :
/// `connected` → online, tout le reste (connecting/reconnecting/disconnected/
/// error) → offline. Aucun package tiers (pas de connectivity_plus).
///
/// Tant qu'on est offline, un timer léger « réveille » le socket via
/// [WebSocketService.reconnectNow] pour qu'il continue d'essayer de se
/// reconnecter même après avoir épuisé ses tentatives internes — sans ça,
/// `onlineStream` resterait bloqué sur `false`.
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._internal();

  ConnectivityService._internal();

  final WebSocketService _socket = WebSocketService.instance;

  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<WebSocketState>? _stateSub;
  Timer? _reviveTimer;
  bool _isOnline = false;
  bool _started = false;

  /// Période de réveil du socket tant qu'on est offline.
  static const Duration _reviveInterval = Duration(seconds: 15);

  /// Flux des transitions online/offline (émissions distinctes uniquement).
  Stream<bool> get onlineStream => _onlineController.stream;

  /// État courant : `true` si le socket est connecté.
  bool get isOnline => _isOnline;

  /// Complète quand la connexion serveur revient.
  ///
  /// Retourne immédiatement `true` si déjà online ; sinon attend la prochaine
  /// transition vers online (sans timeout : garantit le rejeu même après une
  /// coupure prolongée). Plusieurs requêtes suspendues peuvent l'attendre en
  /// parallèle (stream broadcast).
  Future<bool> waitForOnline() async {
    if (_isOnline) return true;
    try {
      return await onlineStream.firstWhere((online) => online);
    } catch (_) {
      return false;
    }
  }

  /// Démarre l'écoute du socket (idempotent).
  void start() {
    if (_started) return;
    _started = true;

    _isOnline = _socket.isConnected;
    _stateSub = _socket.stateStream.listen(_onSocketState);

    // Aligner l'état initial et armer le revive si déjà offline.
    if (!_isOnline) {
      _startReviveTimer();
    }
    deboger('[ConnectivityService] démarré (online=$_isOnline)');
  }

  void _onSocketState(WebSocketState state) {
    final online = state.isConnected;
    if (online == _isOnline) return;

    _isOnline = online;
    _onlineController.add(online);
    deboger('[ConnectivityService] transition → online=$online');

    if (online) {
      _stopReviveTimer();
    } else {
      _startReviveTimer();
    }
  }

  void _startReviveTimer() {
    _reviveTimer?.cancel();
    _reviveTimer = Timer.periodic(_reviveInterval, (_) {
      if (_isOnline) {
        _stopReviveTimer();
        return;
      }
      _socket.reconnectNow();
    });
  }

  void _stopReviveTimer() {
    _reviveTimer?.cancel();
    _reviveTimer = null;
  }

  /// Libère les ressources (à appeler si l'app se ferme proprement).
  void dispose() {
    _stopReviveTimer();
    _stateSub?.cancel();
    _stateSub = null;
    _onlineController.close();
    _started = false;
  }
}
