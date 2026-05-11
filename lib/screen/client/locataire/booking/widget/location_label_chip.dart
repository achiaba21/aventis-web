import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Chip indiquant le niveau de précision de la position affichée — V9.7c.
///
/// Deux variants :
/// - **Exact** (`isExact: true`) — post-réservation `PAYER/FINALISER` :
///   icône `gps_fixed` + texte 'Localisation exacte' couleur `success`, fond
///   `bgElev2` bordure `successLight`. Signal positif (récompense post-paiement).
/// - **Approximatif** (`isExact: false`) — défaut, mode browse : icône
///   `gps_off` + texte 'Localisation approximative' couleur `text3`, fond
///   `bgElev2` bordure `line`. Neutre, muted.
class LocationLabelChip extends StatelessWidget {
  final bool isExact;

  const LocationLabelChip({
    super.key,
    required this.isExact,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = isExact ? Icons.gps_fixed : Icons.gps_off;
    final Color fg = isExact ? AppColors.success : AppColors.text3;
    final Color borderColor =
        isExact ? AppColors.successLight : AppColors.line;
    final String label =
        isExact ? 'Localisation exacte' : 'Localisation approximative';
    final Color textColor = isExact ? AppColors.text : AppColors.text3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.fade,
              softWrap: false,
              maxLines: 1,
              style: AppTextStyles.small.copyWith(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
