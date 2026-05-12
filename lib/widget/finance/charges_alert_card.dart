import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card cliquable d'accès à la gestion des charges depuis Finances.
///
/// Mode "alerte" (`retardCount > 0`) : fond danger soft + icon warning +
/// nombre + montant à régler. Mode "sobre" (`retardCount == 0`) : simple
/// bouton de navigation vers la liste.
class ChargesAlertCard extends StatelessWidget {
  final int retardCount;
  final int retardAmount;
  final VoidCallback onTap;

  const ChargesAlertCard({
    super.key,
    required this.retardCount,
    required this.retardAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (retardCount > 0) {
      return _AlertVariant(
        retardCount: retardCount,
        retardAmount: retardAmount,
        onTap: onTap,
      );
    }
    return _SobreVariant(onTap: onTap);
  }
}

class _AlertVariant extends StatelessWidget {
  final int retardCount;
  final int retardAmount;
  final VoidCallback onTap;

  const _AlertVariant({
    required this.retardCount,
    required this.retardAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 22,
                color: AppColors.danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$retardCount charge${retardCount > 1 ? 's' : ''} en retard',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${FcfaFormatter.full(retardAmount)} à régler',
                      style: AppTextStyles.mono(AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text2,
                      )),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SobreVariant extends StatelessWidget {
  final VoidCallback onTap;

  const _SobreVariant({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            border: Border.all(color: AppColors.line, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Gérer mes charges',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
