import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget affichant les réductions pour séjours longs
/// Palette monochrome : orange + gris uniquement
class RemiseInfo extends StatelessWidget {
  const RemiseInfo({
    super.key,
    required this.remises,
    required this.prixBase,
    this.selectedDays,
  });

  final Remise? remises;
  final double prixBase;

  /// Nombre de jours sélectionnés pour surligner la ligne active
  final int? selectedDays;

  @override
  Widget build(BuildContext context) {
    // Vérifier si des remises existent
    if (remises?.conditions == null || remises!.conditions!.isEmpty) {
      return SizedBox.shrink();
    }

    // Trier les conditions par nombre de jours croissant
    final conditions = List.from(remises!.conditions!)
      ..sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));

    // Trouver la condition active selon les jours sélectionnés
    final activeCondition = selectedDays != null && selectedDays! > 0
        ? remises!.matchCondition(selectedDays!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_offer,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            Gap(Espacement.gapSection),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    "Réductions pour séjours prolongés",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  Gap(2),
                  TextSeed(
                    "Plus vous restez, plus vous économisez",
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),

        Gap(Espacement.gapSection),

        // Cards des réductions (monochrome)
        ...conditions.map((condition) {
          if (condition.days == null || condition.montant == null) {
            return SizedBox.shrink();
          }

          final prixReduit = condition.montant!;
          final prixReduitFormate = prixReduit.toStringAsFixed(0);
          final prixBaseFormate = prixBase.toStringAsFixed(0);
          final pourcentage = ((prixBase - prixReduit) / prixBase * 100).round();

          // Vérifier si cette condition est active
          final isActive = activeCondition?.days == condition.days;

          return Padding(
            padding: EdgeInsets.only(bottom: Espacement.gapItem),
            child: Container(
              padding: EdgeInsets.all(Espacement.paddingBloc),
              decoration: BoxDecoration(
                color: isActive ? AppColors.surfaceVariant : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? Border.all(color: AppColors.accent, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  // Badge pourcentage (toujours orange)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextSeed(
                      "-$pourcentage%",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),

                  Gap(Espacement.gapSection),

                  // Informations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSeed(
                          "${condition.days}+ jours",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        Gap(2),
                        Row(
                          children: [
                            TextSeed(
                              "$prixReduitFormate F/nuit",
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                            Gap(6),
                            Text(
                              "$prixBaseFormate F",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Indicateur actif
                  if (isActive)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
