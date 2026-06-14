import 'package:flutter/widgets.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/realtime/realtime_resource_controller.dart';

/// Branche un écran de détail au temps réel en 2 lignes.
///
/// Dans `initState`, appeler [watchResource] avec le topic ressource et le
/// callback de mise à jour. Le désabonnement est automatique au `dispose`.
///
/// ```dart
/// class _MyDetailState extends State<MyDetail> with RealtimeResourceMixin {
///   @override
///   void initState() {
///     super.initState();
///     watchResource(
///       topic: '/topic/appartement/${widget.id}',
///       onAction: (_) => _reload(),
///       onResync: _reload,
///     );
///   }
/// }
/// ```
mixin RealtimeResourceMixin<T extends StatefulWidget> on State<T> {
  RealtimeResourceController? _realtimeController;

  /// S'abonne au [topic] ressource. [onAction] est appelé à chaque event reçu ;
  /// [onResync] à chaque (re)connexion WS (catch-up).
  void watchResource({
    required String topic,
    required void Function(RealtimeAction action) onAction,
    VoidCallback? onResync,
  }) {
    _realtimeController?.dispose();
    _realtimeController = RealtimeResourceController(
      topic: topic,
      onAction: onAction,
      onResync: onResync,
    )..start();
  }

  @override
  void dispose() {
    _realtimeController?.dispose();
    super.dispose();
  }
}
