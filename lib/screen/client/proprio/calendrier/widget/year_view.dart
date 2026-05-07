import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Vue année : affiche les 12 mois de l'année
///
/// Chaque mois montre un indicateur visuel d'occupation
class YearView extends StatelessWidget {
  const YearView({
    super.key,
    required this.year,
    required this.reservations,
    required this.colorPalette,
    this.onMonthTapped,
  });

  final int year;
  final List<Reservation> reservations;
  final Map<int, Color> colorPalette;
  final Function(int month)? onMonthTapped;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthNumber = index + 1;
        return _buildMonthCell(monthNumber);
      },
    );
  }

  /// Construit une cellule de mois
  Widget _buildMonthCell(int monthNumber) {
    final occupancyRate = _calculateMonthOccupancy(monthNumber);
    final hasReservations = occupancyRate > 0;

    return GestureDetector(
      onTap: () => onMonthTapped?.call(monthNumber),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: hasReservations
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nom du mois
            TextSeed(
              month[monthNumber - 1],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: Espacement.gapSection),

            // Indicateur d'occupation
            if (hasReservations) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(occupancyRate),
                ),
                child: Center(
                  child: TextSeed(
                    '${(occupancyRate * 100).toStringAsFixed(0)}%',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.event_available_outlined,
                size: 32,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Calcule le taux d'occupation d'un mois (approximation)
  double _calculateMonthOccupancy(int month) {
    final lastDay = DateTime(year, month + 1, 0);

    int occupiedDays = 0;
    final totalDays = lastDay.day;

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(year, month, day);
      final isOccupied = reservations.any((r) {
        if (r.statut == ReservationStatus.annulee) return false;
        if (r.debut == null || r.fin == null) return false;

        final start = DateTime(r.debut!.year, r.debut!.month, r.debut!.day);
        final end = DateTime(r.fin!.year, r.fin!.month, r.fin!.day);

        return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));
      });

      if (isOccupied) occupiedDays++;
    }

    return occupiedDays / totalDays;
  }
}
