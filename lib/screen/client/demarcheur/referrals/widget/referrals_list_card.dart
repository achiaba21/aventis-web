import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `ReferralRow` filtrées dans le
/// `DemarcheurReferralsScreen`.
class ReferralsListCard extends StatelessWidget {
  final List<ReferralPreview> referrals;
  final Map<String, Reservation> sourceById;
  final void Function(ReferralPreview referral, Reservation? source)? onTap;

  const ReferralsListCard({
    super.key,
    required this.referrals,
    this.sourceById = const {},
    this.onTap,
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
            for (var i = 0; i < referrals.length; i++)
              ReferralRow(
                referral: referrals[i],
                isLast: i == referrals.length - 1,
                onTap: onTap == null
                    ? null
                    : () => onTap!(
                          referrals[i],
                          sourceById[referrals[i].id],
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
