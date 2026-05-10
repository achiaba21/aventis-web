import 'package:flutter/material.dart';

/// Painter pour le quadrillage du [MapPlaceholder].
///
/// Lignes 1px tous les 28px, couleur très translucide (rgba blanc 0.04).
/// Reproduit l'aspect "carte Mapbox dark" sans tile réelle.
class MapGridPainter extends CustomPainter {
  final double step;
  final Color lineColor;

  const MapGridPainter({this.step = 28, this.lineColor = const Color(0x0AFFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter old) =>
      old.step != step || old.lineColor != lineColor;
}
