import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/map/map_placeholder.dart';
import 'package:asfar/widget/map/map_price_marker.dart';

/// Teaser map du Home Locataire.
///
/// Container 160px de hauteur avec [MapPlaceholder], 4 [MapPriceMarker]
/// positionnés en pourcentages, et un bouton flottant bottom-right
/// "Voir N logements" en blur translucide.
class MapTeaser extends StatelessWidget {
  final List<MapTeaserPin> pins;
  final int totalListings;
  final VoidCallback? onSeeMap;
  final double height;

  const MapTeaser({
    super.key,
    required this.pins,
    required this.totalListings,
    this.onSeeMap,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: MapPlaceholder(
        child: Stack(
          children: [
            for (final p in pins)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment(p.x * 2 - 1, p.y * 2 - 1),
                  child: MapPriceMarker(
                    label: p.label,
                    active: p.active,
                  ),
                ),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSeeMap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xD90A0A0B),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border:
                          Border.all(color: AppColors.line, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined,
                            size: 14, color: AppColors.text),
                        const SizedBox(width: 6),
                        Text(
                          'Voir $totalListings logements',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Données d'un pin sur le [MapTeaser].
///
/// [x] et [y] sont des **pourcentages** (0.0 = top/left, 1.0 = bottom/right)
/// pour positionnement responsive.
class MapTeaserPin {
  final double x;
  final double y;
  final String label;
  final bool active;

  const MapTeaserPin({
    required this.x,
    required this.y,
    required this.label,
    this.active = false,
  });
}
