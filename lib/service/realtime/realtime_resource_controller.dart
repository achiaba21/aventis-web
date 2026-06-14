import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/websocket/websocket_service.dart';
import 'package:asfar/util/function.dart';

/// Abonnement temps réel à UN topic ressource (`/topic/{type}/{id}`) pour un
/// écran de détail — modèle « qui regarde l'objet ».
///
/// - `start()` à l'ouverture : s'abonne au topic ;
/// - chaque event reçu → [onAction] (l'écran recharge sa donnée, ou insère le
///   message pour le chat) ;
/// - sur (re)connexion WS → [onResync] (catch-up : le broker ne rejoue pas les
///   events émis pendant la coupure) ;
/// - `dispose()` à la fermeture : se désabonne.
///
/// Un refus de souscription côté serveur (pas le droit de voir la ressource)
/// est ignoré silencieusement (aucun frame n'est livré). S'utilise via
/// [RealtimeResourceMixin].
class RealtimeResourceController {
  final String topic;
  final void Function(RealtimeAction action) onAction;
  final VoidCallback? onResync;

  StreamSubscription<WebSocketState>? _stateSub;
  bool _wasConnected = false;

  RealtimeResourceController({
    required this.topic,
    required this.onAction,
    this.onResync,
  });

  void start() {
    final ws = WebSocketService.instance;
    _wasConnected = ws.isConnected;
    ws.subscribeTopic(topic, _onFrame);
    _stateSub = ws.stateStream.listen((state) {
      final connected = state.isConnected;
      if (connected && !_wasConnected) {
        onResync?.call();
      }
      _wasConnected = connected;
    });
  }

  void _onFrame(StompFrame frame) {
    try {
      final body = frame.body;
      if (body == null || body.isEmpty) return;
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return;
      onAction(RealtimeAction.fromJson(decoded));
    } catch (e) {
      deboger('⚠️ Frame topic ressource illisible ($topic): $e');
    }
  }

  void dispose() {
    WebSocketService.instance.unsubscribeTopic(topic);
    _stateSub?.cancel();
    _stateSub = null;
  }
}
