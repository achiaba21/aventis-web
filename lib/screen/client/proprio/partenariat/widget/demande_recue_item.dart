import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class DemandeRecueItem extends StatelessWidget {
  final DemandePartenariat demande;
  final VoidCallback? onAccepter;
  final VoidCallback? onRefuser;

  const DemandeRecueItem({
    super.key,
    required this.demande,
    this.onAccepter,
    this.onRefuser,
  });

  bool get _isEnAttente => demande.statut == StatutPartenariat.enAttente;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: demande.initDemarcheur),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      demande.nomDemarcheur,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    if (demande.telephoneDemarcheur.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      TextSeed(
                        demande.telephoneDemarcheur,
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
              if (!_isEnAttente)
                _StatutBadge(label: _statutLabel, color: _statutColor),
            ],
          ),
          if (_isEnAttente) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefuser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccepter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accepter',
                      style: TextStyle(color: AppColors.textOnAccent),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
