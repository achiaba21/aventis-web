import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Légende des couleurs du calendrier
///
/// Affiche la liste des appartements avec leur couleur respective
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({
    super.key,
    required this.appartements,
    required this.colorPalette,
  });

  final List<Appartement> appartements;
  final Map<int, Color> colorPalette;

  @override
  Widget build(BuildContext context) {
    // Ne rien afficher si 1 seul appartement ou moins
    if (appartements.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          TextSeed(
            'Légende',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: Espacement.gapSection),

          // Liste des appartements avec scrolling si nécessaire
          SizedBox(
            height: appartements.length > 5 ? 120 : null,
            child: appartements.length > 5
                ? _buildScrollableLegend()
                : _buildFixedLegend(),
          ),
        ],
      ),
    );
  }

  /// Construit une légende avec scroll (si plus de 5 appartements)
  Widget _buildScrollableLegend() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: appartements.length,
      separatorBuilder: (context, index) => SizedBox(height: Espacement.gapItem),
      itemBuilder: (context, index) {
        final appartement = appartements[index];
        return _buildLegendItem(appartement);
      },
    );
  }

  /// Construit une légende fixe (si 5 appartements ou moins)
  Widget _buildFixedLegend() {
    return Column(
      children: appartements
          .map((appartement) => Padding(
                padding: EdgeInsets.only(bottom: Espacement.gapItem),
                child: _buildLegendItem(appartement),
              ))
          .toList(),
    );
  }

  /// Construit un item de légende (pastille couleur + nom appartement)
  Widget _buildLegendItem(Appartement appartement) {
    final color = colorPalette[appartement.id] ?? AppColors.textMuted;

    return Row(
      children: [
        // Pastille de couleur
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: Espacement.gapSection),

        // Nom de l'appartement
        Expanded(
          child: TextSeed(
            appartement.titre ?? 'Appartement ${appartement.id}',
            fontSize: 13,
            color: AppColors.textPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
