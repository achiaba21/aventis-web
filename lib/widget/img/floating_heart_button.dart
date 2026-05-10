import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton heart flottant sur image (cards listing, detail hero).
///
/// Cercle 34px fond translucide rgba(10,10,11,0.55) + heart blanc.
/// Bascule en heart accent si [active] = true.
class FloatingHeartButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool active;
  final double size;

  const FloatingHeartButton({
    super.key,
    this.onTap,
    this.active = false,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x8C0A0A0B),
          ),
          alignment: Alignment.center,
          child: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: active ? AppColors.accent : Colors.white,
          ),
        ),
      ),
    );
  }
}
