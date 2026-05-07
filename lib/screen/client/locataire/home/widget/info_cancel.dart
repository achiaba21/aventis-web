import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Widget affichant la politique d'annulation
/// avec un design moderne et informatif
class InfoCancel extends StatelessWidget {
  const InfoCancel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_available,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              Gap(Espacement.gapSection),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Annulation flexible",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                    Gap(4),
                    TextSeed(
                      "Politique d'annulation avantageuse",
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Gap(Espacement.gapSection),

          // Informations détaillées
          _buildInfoRow(
            Icons.check_circle_outline,
            "Annulation gratuite jusqu'à 24h après la réservation",
            AppColors.success,
          ),
          Gap(Espacement.gapItem),
          _buildInfoRow(
            Icons.info_outline,
            "Des frais peuvent s'appliquer après cette période",
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        Gap(Espacement.gapItem),
        Expanded(
          child: TextSeed(
            text,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
