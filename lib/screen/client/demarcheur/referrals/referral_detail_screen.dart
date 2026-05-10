import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/commission_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_timeline.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/listing_summary_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Détail d'une référence client — `ReferralDetailScreen`.
///
/// Reproduit `DemarcheurReferralDetail` du prototype : timeline 5 étapes
/// verticales + card résumé du logement + card client + card propriétaire +
/// card commission.
class ReferralDetailScreen extends StatelessWidget {
  final ReferralPreview referral;

  const ReferralDetailScreen({super.key, required this.referral});

  static const _steps = [
    TimelineEntry(
        title: 'Demande envoyée', subtitle: 'il y a 2 j · 8 nov. 09:14'),
    TimelineEntry(
        title: 'Vue par le propriétaire', subtitle: '8 nov. 11:42'),
    TimelineEntry(
        title: 'Acceptée par Aminata K.', subtitle: '9 nov. 08:20'),
    TimelineEntry(
        title: 'Paiement client', subtitle: 'En attente'),
    TimelineEntry(
        title: 'Commission versée', subtitle: 'À venir · vendredi'),
  ];

  int _currentStepIndex(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return 0;
      case ReferralStatus.accepted:
        return 2;
      case ReferralStatus.completed:
        return 4;
      case ReferralStatus.refused:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Demande ${referral.id}',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Statut', style: AppTextStyles.h3),
                  const SizedBox(width: 8),
                  BadgeStatus(
                    text: ReferralStatusDisplay.labelOf(referral.status),
                    tone: ReferralStatusDisplay.toneOf(referral.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReferralTimeline(
                steps: _steps,
                currentIndex: _currentStepIndex(referral.status),
              ),
              const SizedBox(height: 22),
              const Text('Logement', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              ListingSummaryCard(listing: referral.listing),
              const SizedBox(height: 22),
              const Text('Client', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              _clientCard(),
              const SizedBox(height: 22),
              const Text('Propriétaire', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              HostCard(
                hostName: 'Aminata Koné',
                memberSince: '2023',
                certified: true,
                onContactTap: () {},
              ),
              const SizedBox(height: 22),
              const Text('Commission', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              CommissionCard(
                subtotal: referral.subtotal,
                commission: referral.commission,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clientCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          UserAvatar(name: referral.clientName, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.clientName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  referral.clientPhone,
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedCustomButton(
            text: 'Appeler',
            onPressed: () {},
            size: ButtonSize.sm,
            leadingIcon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

}
