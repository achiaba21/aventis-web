import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Container avec bordure dashed (radius arrondi).
///
/// Flutter ne supporte pas nativement `BorderStyle.dashed` sur `Border.all`,
/// donc on utilise un `CustomPainter` qui dessine un rectangle arrondi avec
/// stroke discontinu.
///
/// Utilisé en V7 pour la card « Nouvelle annonce » (`NewListingCard`),
/// réutilisable pour tout futur CTA dashed.
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.color = AppColors.line,
    this.strokeWidth = 1.5,
    this.radius = AppRadii.lg,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rrect);
    final dashedPath = _toDashed(path, dashLength, gapLength);
    canvas.drawPath(dashedPath, paint);
  }

  Path _toDashed(Path source, double dash, double gap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? dash : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) {
    return color != old.color ||
        strokeWidth != old.strokeWidth ||
        radius != old.radius ||
        dashLength != old.dashLength ||
        gapLength != old.gapLength;
  }
}
