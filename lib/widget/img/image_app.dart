import 'package:flutter/material.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/theme/app_colors.dart';

class ImageApp extends StatelessWidget {
  const ImageApp(
    this.name, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.radius = 0,
  });
  final String? name;
  final double? width;
  final double? size;
  final double? height;
  final double radius;

  /// Crée un widget d'erreur qui respecte les dimensions fournies
  Widget _buildErrorWidget() {
    final w = size ?? width;
    final h = size ?? height;

    // Si des dimensions sont spécifiées, créer un container avec ces dimensions
    if (w != null || h != null) {
      // Calculer la taille de l'icône (environ 1/4 de la plus petite dimension, min 24px, max 64px)
      final dimension = (w ?? h ?? 48.0);
      final iconSize = (dimension / 4).clamp(24.0, 64.0);

      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: Icon(
            Icons.broken_image,
            size: iconSize,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    // Sinon, utiliser le comportement par défaut (petite icône)
    return CircleIcon(image: Icons.person, size: 16);
  }

  @override
  Widget build(BuildContext context) {
    final errorWidget = _buildErrorWidget();
    return name == null
        ? errorWidget
        : Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Image.asset(
            name!,
            width: size ?? width ,
            height: size ?? height,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget;
            },
          ),
        );
  }
}
