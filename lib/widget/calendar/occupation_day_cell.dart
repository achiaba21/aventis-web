import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cellule de jour pour le calendrier d'occupation
///
/// Affiche le numéro du jour avec des bandes fines de couleur en bas
/// pour chaque appartement occupé à cette date.
///
/// RÈGLES D'AFFICHAGE :
/// - Si aucune occupation : cellule normale sans bande
/// - Si occupations : bandes fines horizontales en bas (max 3 visibles)
/// - Si plus de 3 occupations : afficher "..." pour indiquer qu'il y en a plus
class OccupationDayCell extends StatelessWidget {
  const OccupationDayCell({
    super.key,
    required this.date,
    required this.occupationColors,
    this.onTap,
    this.isToday = false,
    this.isSelected = false,
    this.isPast = false,
    this.allowPastDates = false,
  });

  final DateTime date;
  final List<Color> occupationColors; // Couleurs des appartements occupés ce jour
  final VoidCallback? onTap;
  final bool isToday;
  final bool isSelected;
  final bool isPast;
  final bool allowPastDates; // Permet de cliquer sur les dates passées (mode propriétaire)

  @override
  Widget build(BuildContext context) {
    // Couleurs et bordures
    Color backgroundColor = isPast ? AppColors.surface : Colors.transparent;
    Color textColor = isPast ? AppColors.textMuted : AppColors.textPrimary;
    Border? border;

    if (isSelected) {
      border = Border.all(color: AppColors.accent, width: 2);
    } else if (isToday) {
      border = Border.all(
        color: AppColors.accent.withValues(alpha: 0.5),
        width: 1,
      );
    }

    return GestureDetector(
      onTap: (isPast && !allowPastDates) ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Numéro du jour
            Expanded(
              child: Center(
                child: TextSeed(
                  '${date.day}',
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),

            // Bandes de couleur (max 3 visibles)
            if (occupationColors.isNotEmpty)
              _buildOccupationBands(occupationColors),
          ],
        ),
      ),
    );
  }

  /// Construit les bandes de couleur pour les occupations
  Widget _buildOccupationBands(List<Color> colors) {
    // Limiter à 3 bandes visibles maximum
    final visibleColors = colors.take(3).toList();
    final hasMore = colors.length > 3;

    return Container(
      height: 8, // Hauteur totale réservée pour les bandes
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // Bandes de couleur
          ...visibleColors.map((color) => Expanded(
                child: Container(
                  height: 3, // Hauteur de chaque bande fine
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: visibleColors.indexOf(color) == 0
                        ? BorderRadius.only(bottomLeft: Radius.circular(8))
                        : (visibleColors.indexOf(color) == visibleColors.length - 1 && !hasMore
                            ? BorderRadius.only(bottomRight: Radius.circular(8))
                            : BorderRadius.zero),
                  ),
                ),
              )),

          // Indicateur "..." s'il y a plus de 3 occupations
          if (hasMore)
            Container(
              width: 8,
              height: 3,
              alignment: Alignment.center,
              child: TextSeed(
                '…',
                fontSize: 8,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
