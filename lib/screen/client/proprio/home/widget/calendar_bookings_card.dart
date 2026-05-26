import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card « Calendrier & bookings » du dashboard proprio.
///
/// Tap → ouvre le `CalendarBookingsScreen`. Sous-titre dynamique :
/// « N séjours en cours » (calculé via `ActiveBookingsCounter` côté caller).
class CalendarBookingsCard extends StatelessWidget {
  final int activeBookingsCount;
  final VoidCallback onTap;

  const CalendarBookingsCard({
    super.key,
    required this.activeBookingsCount,
    required this.onTap,
  });

  String get _subtitle {
    if (activeBookingsCount == 0) {
      return 'Voir la disponibilité de vos annonces';
    }
    final pluriel = activeBookingsCount > 1 ? 's' : '';
    return '$activeBookingsCount séjour$pluriel en cours';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Calendrier & bookings',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitle,
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
