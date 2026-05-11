import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_overlay_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Card centrée affichant un `EmptyState.inline` quand la zone visible
/// ne contient aucun logement.
///
/// Le bouton de fermeture (X) et le dismiss automatique au pan/zoom
/// libèrent la carte — l'utilisateur peut continuer à explorer même si
/// la requête courante a renvoyé 0 résultats.
class MapEmptyOverlay extends StatelessWidget {
  final VoidCallback? onExpandRadius;
  final VoidCallback? onDismiss;

  const MapEmptyOverlay({
    super.key,
    this.onExpandRadius,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapOverlayCard(
          child: EmptyState.inline(
            icon: Icons.location_off_outlined,
            title: 'Aucun logement dans cette zone',
            body: 'Élargissez la zone de recherche ou changez les filtres.',
            ctaLabel: onExpandRadius == null ? null : 'Élargir la zone',
            onCtaTap: onExpandRadius,
          ),
        ),
        if (onDismiss != null)
          Positioned(
            top: 8,
            right: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDismiss,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgElev3,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.text2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
