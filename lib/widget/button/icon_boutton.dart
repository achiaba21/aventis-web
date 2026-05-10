import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton circulaire icon-only du design system Asfar Premium.
///
/// Reproduit `IconBtn` du prototype : cercle [size]×[size], fond `bgElev2`,
/// border `line`, icon centré.
///
/// Variant [floating] : fond translucide rgba(10,10,11,0.6) — pour les boutons
/// flottants sur image (back/share/heart sur fiche detail).
class IconBoutton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final bool floating;
  final String? tooltip;

  const IconBoutton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36,
    this.iconSize = 18,
    this.iconColor,
    this.floating = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: floating
                ? const Color(0x990A0A0B)
                : AppColors.bgElev2,
            border: floating
                ? null
                : Border.all(color: AppColors.line, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.text,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
