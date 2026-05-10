import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card hero "TARIF DE BASE" affichant le prix par nuit d'un logement.
///
/// Utilisé en haut du tab Réductions du `ProprioListingEditScreen`.
class BasePriceCard extends StatelessWidget {
  final int basePrice;

  const BasePriceCard({super.key, required this.basePrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TARIF DE BASE',
              style: AppTextStyles.eyebrow.copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FcfaFormatter.full(basePrice),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '/nuit',
                  style: AppTextStyles.small.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
