import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/map/map_grid_painter.dart';

/// Placeholder de carte du design system Asfar Premium.
///
/// Reproduit `.map-ph` du prototype : gradient sombre + halos radiaux
/// subtils + quadrillage 28px. Le widget prend la place qu'on lui donne ;
/// les overlays (pins, bouton) sont passés via [child] dans un Stack.
class MapPlaceholder extends StatelessWidget {
  final double radius;
  final Widget? child;

  const MapPlaceholder({
    super.key,
    this.radius = AppRadii.lg,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mapBaseStart, AppColors.mapBaseEnd],
          ),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.5, -0.5),
                    radius: 0.7,
                    colors: [Color(0x214ADE80), Colors.transparent],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.7, 0.6),
                    radius: 0.7,
                    colors: [Color(0x2160A5FA), Colors.transparent],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: CustomPaint(painter: MapGridPainter()),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
