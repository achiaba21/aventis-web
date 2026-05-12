import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Chevron bouton tactile pour navigation période/année.
///
/// Atome partagé entre `PeriodNavEyebrow`, `YearSelector` et toute UI qui
/// propose une navigation par chevrons ‹ ›. L'opacité est réduite à
/// `disabledAlpha` quand `enabled = false` pour signaler visuellement
/// l'impossibilité de naviguer.
class AccentChevronButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final double iconSize;
  final double padding;
  final Color color;
  final double disabledAlpha;

  const AccentChevronButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.iconSize = 18,
    this.padding = 2,
    this.color = AppColors.accent,
    this.disabledAlpha = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(
            icon,
            size: iconSize,
            color: color.withValues(alpha: enabled ? 1.0 : disabledAlpha),
          ),
        ),
      ),
    );
  }
}
