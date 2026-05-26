import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Tile d'une option dans la `ContactSheet`.
///
/// Reproduit le style existant de `_ContactSheetTile` (séparateur top,
/// icône à gauche accent or, label centré, chevron à droite) en y ajoutant
/// un état désactivé (`enabled: false`) :
/// - icône en `textDisabled`
/// - label en `textDisabled`
/// - chevron masqué
/// - aucun `InkWell` (tap inerte)
class ContactSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  /// Couleur de l'icône en état actif. Défaut : `AppColors.accent`.
  /// Surcharge utile pour différencier WhatsApp (vert) si besoin futur.
  final Color? activeIconColor;

  const ContactSheetTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.activeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        enabled ? (activeIconColor ?? AppColors.accent) : AppColors.textDisabled;
    final labelColor = enabled ? AppColors.text : AppColors.textDisabled;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: labelColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (enabled)
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.text3,
            ),
        ],
      ),
    );

    if (!enabled) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
