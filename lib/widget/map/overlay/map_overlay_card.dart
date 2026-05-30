import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card centrée flottante au-dessus de la carte, utilisée comme conteneur
/// commun pour les 3 overlays partagés (Loading / Empty / Error).
///
/// Style partagé : fond `bgElev1` semi-opaque, border `line`, radius `lg`,
/// shadow profonde pour ressortir sur les tuiles OSM dark filtered.
class MapOverlayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const MapOverlayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.bgElev1.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
