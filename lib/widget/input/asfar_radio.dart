import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Radio custom du design system Asfar Premium.
///
/// Cercle 20px : inactif = border 1.5px `text3`, actif = anneau accent 6px
/// + centre transparent. Cohérent avec le proto (`Étape 2 — Paiement`).
class AsfarRadio extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  const AsfarRadio({
    super.key,
    required this.selected,
    required this.onTap,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.text3,
            width: selected ? 6 : 1.5,
          ),
        ),
      ),
    );
  }
}
