import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_overlay_card.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Card centrée affichant un `EmptyState.error` en cas d'erreur réseau
/// pendant le chargement des résidences.
class MapErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MapErrorOverlay({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MapOverlayCard(
      child: EmptyState.error(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
