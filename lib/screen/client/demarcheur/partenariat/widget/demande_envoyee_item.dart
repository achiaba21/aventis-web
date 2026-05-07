import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class DemandeEnvoyeeItem extends StatelessWidget {
  final DemandePartenariat demande;

  const DemandeEnvoyeeItem({super.key, required this.demande});

  Color get _statutColor {
    switch (demande.statut) {
      case StatutPartenariat.acceptee:
        return AppColors.success;
      case StatutPartenariat.refusee:
        return AppColors.error;
      case StatutPartenariat.enAttente:
        return AppColors.accent;
    }
  }

  String get _statutLabel {
    switch (demande.statut) {
      case StatutPartenariat.acceptee:
        return 'Acceptée';
      case StatutPartenariat.refusee:
        return 'Refusée';
      case StatutPartenariat.enAttente:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Avatar(initial: demande.initProprietaire),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  demande.nomProprietaire,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                if (demande.telephoneProprietaire.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  TextSeed(
                    demande.telephoneProprietaire,
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ],
                const SizedBox(height: 4),
                TextSeed(
                  '${demande.createdAt.day.toString().padLeft(2, '0')}/${demande.createdAt.month.toString().padLeft(2, '0')}/${demande.createdAt.year}',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatutBadge(label: _statutLabel, color: _statutColor),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: TextSeed(
          initial,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatutBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: TextSeed(
        label,
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
