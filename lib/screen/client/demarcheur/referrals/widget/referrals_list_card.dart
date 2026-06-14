import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `ReferralRow` filtrées dans le
/// `DemarcheurReferralsScreen`.
class ReferralsListCard extends StatelessWidget {
  final List<Reservation> reservations;
  final void Function(Reservation reservation)? onTap;

  const ReferralsListCard({
    super.key,
    required this.reservations,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Simple marge de respiration en bas de liste. La BottomNav est dégagée par
    // le SafeArea de l'écran, et la bande du bouton « Nouvelle demande » est
    // réservée en amont via un Padding dédié — inutile de la compenser ici.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
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
              ReferralRow(
                reservation: reservations[i],
                isLast: i == reservations.length - 1,
                onTap: onTap == null
                    ? null
                    : () => onTap!(reservations[i]),
              ),
          ],
        ),
      ),
    );
  }
}
