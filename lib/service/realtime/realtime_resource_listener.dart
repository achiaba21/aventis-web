import 'package:flutter/widgets.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/realtime/realtime_resource_controller.dart';

/// Enveloppe un sous-arbre pour le brancher au temps réel d'UNE ressource
/// (`/topic/{type}/{id}`) — modèle « qui regarde l'objet ».
///
/// Universel : fonctionne quel que soit le parent (écran `StatelessWidget` ou
/// `StatefulWidget`). Les callbacks reçoivent le `BuildContext` du listener
/// (sous les `BlocProvider` de l'écran) pour pouvoir `context.read<XBloc>()`.
///
/// ```dart
/// RealtimeResourceListener(
///   topic: '/topic/reservation/$reference',
///   onAction: (ctx, _) => ctx.read<ReservationDetailBloc>().add(RefreshFromApi()),
///   onResync: (ctx) => ctx.read<ReservationDetailBloc>().add(RefreshFromApi()),
///   child: body,
/// )
/// ```
class RealtimeResourceListener extends StatefulWidget {
  /// Topic ressource STOMP (ex. `/topic/appartement/42`).
  final String topic;

  /// Appelé à chaque event reçu sur le topic.
  final void Function(BuildContext context, RealtimeAction action) onAction;

  /// Appelé à chaque (re)connexion WS (catch-up : recharger l'écran).
  final void Function(BuildContext context)? onResync;

  final Widget child;

  const RealtimeResourceListener({
    super.key,
    required this.topic,
    required this.onAction,
    this.onResync,
    required this.child,
  });

  @override
  State<RealtimeResourceListener> createState() =>
      _RealtimeResourceListenerState();
}

class _RealtimeResourceListenerState extends State<RealtimeResourceListener> {
  RealtimeResourceController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = RealtimeResourceController(
      topic: widget.topic,
      onAction: (action) {
        if (mounted) widget.onAction(context, action);
      },
      onResync: widget.onResync == null
          ? null
          : () {
              if (mounted) widget.onResync!(context);
            },
    )..start();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
