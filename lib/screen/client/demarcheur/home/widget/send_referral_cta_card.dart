import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card CTA « Envoyer un client à un propriétaire » — gradient or subtil.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurDashboard` (lignes 74-91) :
/// gradient horizontal accent translucide, border accent 0.25, badge carré
/// 44 px accent or avec icon send + label fort + sous-label + arrow.
class SendReferralCtaCard extends StatelessWidget {
  final VoidCallback? onTap;

  const SendReferralCtaCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.accent.withValues(alpha: 0.10),
                AppColors.accent.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_outlined,
                    size: 20, color: AppColors.onAccent),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Envoyer un client à un propriétaire',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Créer une demande de réservation',
                      style: TextStyle(fontSize: 12, color: AppColors.text2),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
