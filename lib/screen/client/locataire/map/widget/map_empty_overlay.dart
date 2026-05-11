import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_overlay_card.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Card centrée affichant un `EmptyState.inline` quand la zone visible
/// ne contient aucun logement.
class MapEmptyOverlay extends StatelessWidget {
  final VoidCallback? onExpandRadius;

  const MapEmptyOverlay({super.key, this.onExpandRadius});

  @override
  Widget build(BuildContext context) {
    return MapOverlayCard(
      child: EmptyState.inline(
        icon: Icons.location_off_outlined,
        title: 'Aucun logement dans cette zone',
        body: 'Élargissez la zone de recherche ou changez les filtres.',
        ctaLabel: onExpandRadius == null ? null : 'Élargir la zone',
        onCtaTap: onExpandRadius,
      ),
    );
  }
}
