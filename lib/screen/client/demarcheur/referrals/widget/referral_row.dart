import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Ligne d'une référence client référée — Dashboard + Referrals screen.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurDashboard` (mock
/// `ReferralRow`) : ImgPh tone 36 px à gauche + nom client + badge statut +
/// info logement/nuits + commission accent or à droite + chevron.
class ReferralRow extends StatelessWidget {
  final ReferralPreview referral;
  final VoidCallback? onTap;
  final bool isLast;

  const ReferralRow({
    super.key,
    required this.referral,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.line, width: 1),
                  ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: ImgPh(tone: referral.listing.tone, radius: 10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            referral.clientName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        BadgeStatus(
                          text: ReferralStatusDisplay.labelOf(referral.status),
                          tone: ReferralStatusDisplay.toneOf(referral.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${referral.listing.title} · ${referral.nights} nuits',
                      style: AppTextStyles.small.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FcfaFormatter.compact(referral.commission),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
