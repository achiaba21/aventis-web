import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_timeline_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/calc/reservation_timeline_builder.dart';

/// Timeline (stepper vertical) des événements de la réservation.
///
/// Card bgElev1 + border line. Une `ReservationDetailTimelineRow` par
/// événement reconstruit par `ReservationTimelineBuilder`.
class ReservationDetailTimeline extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailTimeline({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final events = ReservationTimelineBuilder.build(reservation);
    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < events.length; i++)
            ReservationDetailTimelineRow(
              event: events[i],
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}
