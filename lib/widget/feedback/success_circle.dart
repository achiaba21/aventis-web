import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cercle de succès du design Asfar Premium — utilisé dans les écrans
/// de confirmation (réservation, demande envoyée).
///
/// Cercle 88×88 fond accent or + icon centré + double halo concentrique
/// (rgba 0.12 sur 14px puis rgba 0.06 sur 28px).
class SuccessCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color iconColor;

  const SuccessCircle({
    super.key,
    this.icon = Icons.check,
    this.size = 88,
    this.color = AppColors.accent,
    this.iconColor = AppColors.onAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 0,
            spreadRadius: 14,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 0,
            spreadRadius: 28,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.48, color: iconColor),
    );
  }
}
