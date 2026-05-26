import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/booking_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section « Réservations du mois » du `CalendarBookingsScreen`.
///
/// Header + liste verticale de `BookingRow`. Empty state si aucune résa.
class MonthBookingsList extends StatelessWidget {
  final List<Reservation> reservations;
  final void Function(Reservation r)? onTap;

  const MonthBookingsList({
    super.key,
    required this.reservations,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Réservations du mois',
                style: AppTextStyles.h3,
              ),
            ),
            Text(
              '${reservations.length} séjour${reservations.length > 1 ? 's' : ''}',
              style: AppTextStyles.small.copyWith(
                fontSize: 12,
                color: AppColors.text3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reservations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Aucune réservation ce mois-ci.',
              style: AppTextStyles.small.copyWith(
                fontSize: 13,
                color: AppColors.text3,
              ),
            ),
          )
        else
          for (var i = 0; i < reservations.length; i++) ...[
            BookingRow(
              reservation: reservations[i],
              onTap: onTap == null ? null : () => onTap!(reservations[i]),
            ),
            if (i < reservations.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}
