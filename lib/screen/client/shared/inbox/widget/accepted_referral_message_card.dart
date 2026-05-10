import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card spéciale « Demande acceptée » — `MessagingThreadScreen` côté
/// démarcheur.
///
/// Reproduit le proto `extras.jsx::MessagingThread` (lignes 234-246) :
/// Container `accentSoft` border `accent×0.25` maxWidth 82% padding 12 +
/// Row[icon check 16 accent strokeWidth 2.6 + label « Demande acceptée »
/// 13 w700 accent] + sub 11 small + commission mono 13 w700.
///
/// Tap = SnackBar « Détail référence disponible prochainement ».
class AcceptedReferralMessageCard extends StatelessWidget {
  final AcceptedReferralCardPayload payload;
  final VoidCallback? onTap;

  const AcceptedReferralMessageCard({
    super.key,
    required this.payload,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Demande acceptée',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${payload.referralCode} · ${payload.contextLabel}',
                    style: AppTextStyles.small.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Commission: +${FcfaFormatter.full(payload.commission)}',
                    style: AppTextStyles.mono(const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
