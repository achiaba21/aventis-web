import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Légende du calendrier d'occupation
///
/// Affiche la liste des appartements avec leur couleur respective.
///
/// RÈGLES D'AFFICHAGE :
/// - Chaque appartement = carré de couleur + nom
/// - Disposition en colonne pour lisibilité (peut devenir long)
/// - Si aucun appartement : ne rien afficher
class OccupationLegend extends StatelessWidget {
  const OccupationLegend({
    super.key,
    required this.apartmentColors,
  });

  /// Map : apartmentId → (color, name)
  final Map<int, ({Color color, String name})> apartmentColors;

  @override
  Widget build(BuildContext context) {
    if (apartmentColors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          'Légende',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        Gap(Espacement.gapItem),
        Wrap(
          spacing: Espacement.gapSection,
          runSpacing: Espacement.gapItem,
          children: apartmentColors.entries
              .map((entry) => _buildLegendItem(
                    entry.value.color,
                    entry.value.name,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Gap(4),
        TextSeed(
          label,
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
