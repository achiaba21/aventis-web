import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Mes clients référés » du `DemarcheurDashboard` — SectionHeader
/// + liste de `ReferralRow` (ou EmptyState avec CTA si vide). Consomme
/// directement `List<Reservation>` filtrée par le dashboard.
class DemarcheurReferralsSection extends StatelessWidget {
  final List<Reservation> reservations;
  final VoidCallback? onSeeAll;
  final VoidCallback? onAddReferral;
  final void Function(Reservation reservation)? onReferralTap;

  const DemarcheurReferralsSection({
    super.key,
    required this.reservations,
    this.onSeeAll,
    this.onAddReferral,
    this.onReferralTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Mes clients référés',
          actionLabel: 'Tout voir',
          onActionTap: onSeeAll,
        ),
        if (reservations.isEmpty)
          EmptyState.inline(
            icon: Icons.people_outline,
            title: 'Aucun client référé',
            body:
                'Envoyez votre première demande pour commencer à gagner des commissions.',
            ctaLabel: 'Nouvelle demande',
            onCtaTap: onAddReferral,
          )
        else
          Container(
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
                    onTap: onReferralTap == null
                        ? null
                        : () => onReferralTap!(reservations[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
