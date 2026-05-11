import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Ligne compacte d'annonce — Dashboard propriétaire section « Mes annonces ».
///
/// Consomme directement [Appartement]. Reproduit le proto
/// `proprietaire.jsx::ProprietaireDashboard` (lignes 126-146) : `ImgPh` 64×64
/// tone + titre + ville + badge `● Actif` + occupation% + revenus du mois.
class ProprioListingRow extends StatelessWidget {
  final Appartement appartement;
  final double occupancyRate;
  final int monthlyRevenue;
  final VoidCallback? onTap;

  const ProprioListingRow({
    super.key,
    required this.appartement,
    required this.occupancyRate,
    required this.monthlyRevenue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyPct = (occupancyRate * 100).round();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: ImgPh(tone: appartement.tone, radius: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appartement.titleSafe,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appartement.areaName,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const BadgeStatus(
                          text: '● Actif',
                          tone: BadgeTone.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$occupancyPct% occup.',
                          style: AppTextStyles.small.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FcfaFormatter.compact(monthlyRevenue),
                    style: AppTextStyles.mono(const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    )),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ce mois',
                    style: AppTextStyles.small.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
