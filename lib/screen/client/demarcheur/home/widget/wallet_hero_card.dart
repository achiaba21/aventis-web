import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/mini_stats_inline.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Hero card du Dashboard démarcheur — gradient bleu-nuit + halo radial bleu
/// + montant 32 px + delta + mini-stats inline.
///
/// Reproduit fidèlement le proto `demarcheur.jsx::DemarcheurDashboard`
/// (lignes 30-72) : gradient 3 stops `[#1A2A4A → #0E1626 → #060A14]`,
/// border bleue translucide, padding 18, radius 22.
class WalletHeroCard extends StatelessWidget {
  final int monthCommission;
  final int deltaPercent;
  final int totalCommission;
  final int pendingCommission;
  final int clientsCount;

  const WalletHeroCard({
    super.key,
    required this.monthCommission,
    required this.deltaPercent,
    required this.totalCommission,
    required this.pendingCommission,
    required this.clientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientBlue,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.walletBlueBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.walletBlueHalo, Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MES COMMISSIONS CE MOIS',
                      style: AppTextStyles.eyebrow.copyWith(
                        color: AppColors.walletBlueAccent,
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: AppColors.walletBlueAccent),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  FcfaFormatter.full(monthCommission),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: Colors.white,
                  )),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    BadgeStatus(
                      text: '↑ $deltaPercent%',
                      tone: BadgeTone.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'vs. octobre',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MiniStatsInline(
                  items: [
                    MiniStatItem(
                      label: 'Cumul total',
                      value: FcfaFormatter.compact(totalCommission),
                    ),
                    MiniStatItem(
                      label: 'En attente',
                      value: FcfaFormatter.compact(pendingCommission),
                      valueColor: AppColors.warn,
                    ),
                    MiniStatItem(
                      label: 'Clients',
                      value: '$clientsCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
