import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/listing_push_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/send_referral_cta_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pills_row.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/wallet_hero_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/new_referral_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/screen/client/demarcheur/sample/sample_listings_to_referral.dart';
import 'package:asfar/screen/client/demarcheur/sample/sample_referrals.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Dashboard du Démarcheur — Vague 6.
///
/// Reproduit `DemarcheurDashboard` du prototype : header greeting +
/// `WalletHeroCard` + CTA « Envoyer un client » + `StatusPillsRow` + section
/// « Mes clients référés » + carrousel « Logements à pousser ».
class DemarcheurDashboard extends StatelessWidget {
  final String firstName;

  const DemarcheurDashboard({super.key, this.firstName = 'Diallo'});

  void _onOpenNew(BuildContext context) {
    pushScreen(context, const NewReferralScreen());
  }

  void _onOpenReferralDetail(BuildContext context, int index) {
    pushScreen(
      context,
      ReferralDetailScreen(referral: SampleReferrals.all[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final referrals = SampleReferrals.all.take(3).toList();
    final pushListings = SampleListingsToReferral.listings;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Bonjour, $firstName',
        eyebrow: 'TABLEAU DE BORD',
        trailing: IconBoutton(
          icon: Icons.notifications_none,
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WalletHeroCard(
                monthCommission: 228000,
                deltaPercent: 32,
                totalCommission: 1240000,
                pendingCommission: 64000,
                clientsCount: 27,
              ),
              const SizedBox(height: 16),
              SendReferralCtaCard(onTap: () => _onOpenNew(context)),
              const SizedBox(height: 22),
              const StatusPillsRow(
                items: [
                  StatusPillItem(
                    value: '3',
                    label: 'En attente',
                    valueColor: AppColors.warn,
                  ),
                  StatusPillItem(
                    value: '12',
                    label: 'Acceptées',
                    valueColor: AppColors.success,
                  ),
                  StatusPillItem(
                    value: '89%',
                    label: 'Taux acceptation',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SectionHeader(
                title: 'Mes clients référés',
                actionLabel: 'Tout voir',
                onActionTap: () {},
              ),
              Container(
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
                        onTap: () => _onOpenReferralDetail(context, i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SectionHeader(
                title: 'Logements à pousser',
                actionLabel: 'Voir tout',
                onActionTap: () {},
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: pushListings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final l = pushListings[i];
                    return ListingPushCard(
                      listing: l,
                      estimatedCommission:
                          SampleListingsToReferral.commissionFor(l),
                      onTap: () => _onOpenNew(context),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Astuce : les biens à forte note convertissent +30 %.',
                style: AppTextStyles.small.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
