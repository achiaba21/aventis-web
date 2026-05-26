import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card récap montant du wizard (steps 2 et 3).
///
/// Affiche `N nuits × prixNuit = totalClient` puis `Vous recevez =
/// totalRecuProprio` (= total - commission éventuelle).
class ReservationRecapCard extends StatelessWidget {
  final int nbNuits;
  final int prixNuit;
  final int totalClient;
  final int totalRecuProprio;

  const ReservationRecapCard({
    super.key,
    required this.nbNuits,
    required this.prixNuit,
    required this.totalClient,
    required this.totalRecuProprio,
  });

  @override
  Widget build(BuildContext context) {
    final ligne1 = '$nbNuits nuit${nbNuits > 1 ? 's' : ''} × ${FcfaFormatter.compact(prixNuit)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ligne1,
                  style: AppTextStyles.body
                      .copyWith(fontSize: 13, color: AppColors.text2),
                ),
              ),
              Text(
                FcfaFormatter.full(totalClient),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vous recevez',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                FcfaFormatter.full(totalRecuProprio),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
