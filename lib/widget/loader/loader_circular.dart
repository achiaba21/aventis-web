import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Spinner circulaire du design system Asfar Premium.
///
/// `CircularProgressIndicator` accent or, taille configurable.
class LoaderCircular extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoaderCircular({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.accent),
      ),
    );
  }
}
