import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card "Détail du prix" du tunnel Reserve.
///
/// Lignes label/valeur (prix × nuits, frais), divider, ligne Total en
/// gras avec mono.
class PriceDetailCard extends StatelessWidget {
  final List<PriceLine> lines;
  final int total;

  const PriceDetailCard({
    super.key,
    required this.lines,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    line.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text2,
                    ),
                  ),
                  Text(
                    FcfaFormatter.full(line.amount),
                    style: AppTextStyles.mono(const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                    )),
                  ),
                ],
              ),
            ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: AppColors.line,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                FcfaFormatter.full(total),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ligne du [PriceDetailCard].
class PriceLine {
  final String label;
  final int amount;
  const PriceLine({required this.label, required this.amount});
}
