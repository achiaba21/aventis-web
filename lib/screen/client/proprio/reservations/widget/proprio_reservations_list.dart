import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/proprio_reservation_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `ProprioReservationRow` filtrées.
class ProprioReservationsList extends StatelessWidget {
  final List<Reservation> reservations;
  final void Function(Reservation reservation)? onRowTap;

  const ProprioReservationsList({
    super.key,
    required this.reservations,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < reservations.length; i++)
              ProprioReservationRow(
                reservation: reservations[i],
                isLast: i == reservations.length - 1,
                onTap: onRowTap == null
                    ? null
                    : () => onRowTap!(reservations[i]),
              ),
          ],
        ),
      ),
    );
  }
}
