import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Container icon 40×40 accent or pour le côté gauche des cards système
/// du chat (V9.2). Partagé entre `ReservationMessageCard` et
/// `AcceptedPartenariatMessageCard`.
class SystemCardLeadingIcon extends StatelessWidget {
  final IconData icon;

  const SystemCardLeadingIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Icon(
        icon,
        size: 20,
        color: AppColors.accent,
      ),
    );
  }
}

/// Chip "Indisponible" — affiché quand le fetch lazy d'une card système
/// a échoué. Couleur muted `text3` (pas warn/danger) pour rester silencieux.
class SystemCardUnavailableChip extends StatelessWidget {
  const SystemCardUnavailableChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 12, color: AppColors.text3),
          const SizedBox(width: 4),
          Text(
            'Indisponible',
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Zones gris `bgElev2` qui pré-figurent le contenu pendant le fetch lazy
/// des cards système. Pattern statique sans shimmer (cohérent V9.7c
/// MapMarkerBottomSheet).
///
/// [rowWidths] détermine la largeur de chaque zone, l'ordre déterminant
/// le rendu vertical. La 1ère zone est plus haute (14px, titre), les
/// suivantes plus courtes (12px sub, 11px footer mono).
class SystemCardSkeletonRows extends StatelessWidget {
  final List<double> rowWidths;

  const SystemCardSkeletonRows({super.key, required this.rowWidths});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rowWidths.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          Container(
            width: rowWidths[i],
            height: i == 0 ? 14 : (i == 1 ? 12 : 11),
            decoration: BoxDecoration(
              color: AppColors.bgElev2,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
        ],
      ],
    );
  }
}
