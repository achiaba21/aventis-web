import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card affichant l'appartement lié à la charge (nom + résidence éventuelle).
class ChargeDetailAppartCard extends StatelessWidget {
  final Charge charge;

  const ChargeDetailAppartCard({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    final nom = charge.appartementNom?.trim();
    final residence = charge.residenceNom?.trim();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.bgElev2,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.home_outlined,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (nom == null || nom.isEmpty) ? '—' : nom,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (residence != null && residence.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    residence,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
