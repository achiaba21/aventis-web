import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Placeholder d'image du design system Asfar Premium.
///
/// Reproduit `.img-ph` du prototype : `LinearGradient` 135° (3 stops sombres)
/// + halo `RadialGradient` accent en haut-gauche.
///
/// 4 tones : 1 (or), 2 (vert), 3 (violet), 4 (bleu) — alignés sur les
/// `AppColors.tonalGradient1-4` et `AppColors.tonalHalo1-4`.
///
/// Le widget prend la place qu'on lui donne (aspect ratio géré par le parent).
/// `child` permet d'empiler des éléments par-dessus (badges, dots, heart).
class ImgPh extends StatelessWidget {
  final int tone;
  final double radius;
  final Widget? child;

  const ImgPh({
    super.key,
    this.tone = 1,
    this.radius = AppRadii.lg,
    this.child,
  });

  List<Color> get _gradientColors {
    switch (tone) {
      case 2:
        return AppColors.tonalGradient2;
      case 3:
        return AppColors.tonalGradient3;
      case 4:
        return AppColors.tonalGradient4;
      case 1:
      default:
        return AppColors.tonalGradient1;
    }
  }

  Color get _haloColor {
    switch (tone) {
      case 2:
        return AppColors.tonalHalo2;
      case 3:
        return AppColors.tonalHalo3;
      case 4:
        return AppColors.tonalHalo4;
      case 1:
      default:
        return AppColors.tonalHalo1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.6),
                  radius: 0.6,
                  colors: [_haloColor, Colors.transparent],
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
