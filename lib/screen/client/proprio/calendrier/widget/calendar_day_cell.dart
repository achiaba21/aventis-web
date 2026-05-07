import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Cellule de jour pour le calendrier global
///
/// Affiche le numéro du jour avec des bandes de couleur en bas
/// pour indiquer les occupations (une bande = un appartement occupé)
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    this.occupationColors = const [],
    this.isToday = false,
    this.isCurrentMonth = true,
    this.onTap,
  });

  final int day;
  final List<Color> occupationColors; // Couleurs des appartements occupés
  final bool isToday;
  final bool isCurrentMonth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Couleur du texte
    Color textColor = AppColors.textPrimary;
    if (!isCurrentMonth) {
      textColor = AppColors.textMuted;
    }

    // Couleur de fond si aujourd'hui
    Color? backgroundColor;
    Border? border;
    if (isToday) {
      backgroundColor = AppColors.accent.withOpacity(0.1);
      border = Border.all(color: AppColors.accent, width: 2);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Numéro du jour
            Expanded(
              child: Center(
                child: TextSeed(
                  '$day',
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),

            // Bandes de couleur pour les occupations (max 3 visibles)
            if (occupationColors.isNotEmpty) _buildOccupationBands(),
          ],
        ),
      ),
    );
  }

  /// Construit les bandes de couleur pour les occupations
  Widget _buildOccupationBands() {
    // Limiter à 3 bandes visibles
    final visibleColors = occupationColors.take(3).toList();
    final hasMore = occupationColors.length > 3;

    return Container(
      height: 6,
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: Espacement.gapItem / 2,
        left: Espacement.gapItem / 2,
        right: Espacement.gapItem / 2,
      ),
      child: Row(
        children: [
          // Bandes de couleur
          ...visibleColors.map((color) => Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              )),

          // Indicateur "..." si plus de 3 occupations
          if (hasMore)
            Container(
              width: 6,
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
