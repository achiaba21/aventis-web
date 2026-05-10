import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Séparateur fin du design system Asfar Premium.
///
/// Ligne 1px `line` (rgba 8% blanc). Utilisé entre sections de cards et
/// dans les listrows.
class AsfarDivider extends StatelessWidget {
  final double height;
  final EdgeInsets margin;
  final Color color;

  const AsfarDivider({
    super.key,
    this.height = 1,
    this.margin = EdgeInsets.zero,
    this.color = AppColors.line,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      color: color,
    );
  }
}
