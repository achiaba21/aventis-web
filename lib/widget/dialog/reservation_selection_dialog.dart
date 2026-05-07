import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/occupation/occupation_period.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:gap/gap.dart';
import 'package:asfar/theme/app_colors.dart';

/// Dialog de sélection de réservation
///
/// Affiché quand plusieurs réservations se chevauchent sur une même date.
/// Permet au propriétaire de choisir quelle réservation consulter.
class ReservationSelectionDialog extends StatelessWidget {
  const ReservationSelectionDialog({
    super.key,
    required this.periods,
    required this.selectedDate,
  });

  final List<OccupationPeriod> periods;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            'Sélectionner une réservation',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          Gap(Espacement.gapItem),
          TextSeed(
            '${selectedDate.day} ${month[selectedDate.month - 1]} ${selectedDate.year}',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: periods.length,
          separatorBuilder: (context, index) => Gap(Espacement.gapSection),
          itemBuilder: (context, index) {
            final period = periods[index];
            return _PeriodItem(
              period: period,
              onTap: () => Navigator.pop(context, period),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextSeed(
            'Annuler',
            color: AppColors.textPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Affiche le dialog et retourne la période choisie ou null si annulé
  static Future<OccupationPeriod?> show({
    required BuildContext context,
    required List<OccupationPeriod> periods,
    required DateTime selectedDate,
  }) async {
    return await showDialog<OccupationPeriod>(
      context: context,
      builder: (context) => ReservationSelectionDialog(
        periods: periods,
        selectedDate: selectedDate,
      ),
    );
  }
}

/// Item de période dans la liste
class _PeriodItem extends StatelessWidget {
  const _PeriodItem({
    required this.period,
    required this.onTap,
  });

  final OccupationPeriod period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Espacement.radius),
      child: Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Espacement.radius),
              ),
              child: Icon(
                Icons.home,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            Gap(Espacement.gapSection),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    period.appartementName ?? 'Appartement ${period.appartementId}',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  Gap(Espacement.gapItem),
                  TextSeed(
                    _formatPeriodDates(),
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Formate les dates de la période
  String _formatPeriodDates() {
    final startDay = period.startDate.day;
    final startMonth = month[period.startDate.month - 1];
    final endDay = period.endDate.day;
    final endMonth = month[period.endDate.month - 1];

    if (period.startDate.month == period.endDate.month) {
      return 'Du $startDay au $endDay $startMonth ${period.endDate.year}';
    }
    return 'Du $startDay $startMonth au $endDay $endMonth ${period.endDate.year}';
  }
}
