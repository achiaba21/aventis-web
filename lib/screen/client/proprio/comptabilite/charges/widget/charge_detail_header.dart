import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/charge_status_display.dart';
import 'package:asfar/widget/badge/badge_status.dart';

/// Header sobre du `ChargeDetailScreen` : icône type + libellé + appart + badge.
///
/// Pas de hero gradient — l'or reste réservé aux revenus.
class ChargeDetailHeader extends StatelessWidget {
  final Charge charge;

  const ChargeDetailHeader({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    final statut = ChargeStatusDisplay.statutOf(charge);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              charge.typeCharge.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  charge.labelComplet,
                  style: AppTextStyles.h2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((charge.appartementNom ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    charge.appartementNom!,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 13,
                      color: AppColors.text3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                BadgeStatus(
                  text: ChargeStatusDisplay.labelOf(statut),
                  tone: ChargeStatusDisplay.toneOf(statut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
