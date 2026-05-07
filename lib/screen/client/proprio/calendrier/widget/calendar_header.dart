import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/calendar/calendar_view_mode.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// En-tête du calendrier global
///
/// Affiche :
/// - Titre du mois/année selon la vue
/// - Taux d'occupation
/// - Badge de notifications (réservations en attente)
/// - Bouton "Aujourd'hui"
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.mode,
    required this.currentDate,
    required this.pendingCount,
    required this.occupancyRate,
    this.onTodayPressed,
    this.onPreviousPressed,
    this.onNextPressed,
  });

  final CalendarViewMode mode;
  final DateTime currentDate;
  final int pendingCount;
  final double occupancyRate;
  final VoidCallback? onTodayPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Column(
        children: [
          // Ligne 1 : Navigation mois/année
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton précédent
              IconButton(
                onPressed: onPreviousPressed,
                icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // Titre (mois + année ou année seule)
              TextSeed(
                _getTitle(),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),

              // Bouton suivant
              IconButton(
                onPressed: onNextPressed,
                icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: Espacement.gapSection),

          // Ligne 2 : Stats + Bouton Today
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Taux d'occupation
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: Espacement.gapItem),
                  TextSeed(
                    '${(occupancyRate * 100).toStringAsFixed(0)}% occupé',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              // Badge réservations en attente + Bouton Today
              Row(
                children: [
                  // Badge notifications
                  if (pendingCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Espacement.paddingInput,
                        vertical: Espacement.gapItem,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Espacement.radius),
                        border: Border.all(
                          color: AppColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pending_outlined,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: Espacement.gapItem),
                          TextSeed(
                            '$pendingCount',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ),

                  if (pendingCount > 0) SizedBox(width: Espacement.gapSection),

                  // Bouton "Aujourd'hui"
                  GestureDetector(
                    onTap: onTodayPressed,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Espacement.paddingInput,
                        vertical: Espacement.gapItem,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Espacement.radius),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 1,
                        ),
                      ),
                      child: TextSeed(
                        "Aujourd'hui",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retourne le titre selon le mode de vue
  String _getTitle() {
    switch (mode) {
      case CalendarViewMode.year:
        return '${currentDate.year}';
      case CalendarViewMode.month:
      case CalendarViewMode.days:
        return '${month[currentDate.month - 1]} ${currentDate.year}';
    }
  }
}
