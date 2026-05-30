import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/map/overlay/map_overlay_card.dart';

/// Petite card centrée bgElev1 avec spinner accent + "Chargement…".
/// Non-bloquante : la carte reste visible/interactive en dessous.
class MapLoadingOverlay extends StatelessWidget {
  const MapLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return MapOverlayCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(width: 10),
          Text('Chargement…', style: AppTextStyles.small),
        ],
      ),
    );
  }
}
