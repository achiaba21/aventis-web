import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Carte affichant le solde disponible avec bouton de retrait
class SoldeCard extends StatelessWidget {
  final double soldeDisponible;
  final bool compteActif;
  final VoidCallback? onRetrait;

  const SoldeCard({
    super.key,
    required this.soldeDisponible,
    this.compteActif = true,
    this.onRetrait,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: compteActif
              ? [AppColors.success, AppColors.success]
              : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextSeed(
                    "SOLDE DISPONIBLE",
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              if (!compteActif)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextSeed(
                    "SUSPENDU",
                    fontSize: 10,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextSeed(
            "${ComptabiliteCalculator.formatMontant(soldeDisponible)} FCFA",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: compteActif && soldeDisponible > 0 ? onRetrait : null,
              icon: const Icon(Icons.send, size: 18),
              label: TextSeed(
                "Demander un retrait",
                color: compteActif && soldeDisponible > 0
                    ? AppColors.success
                    : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.white.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte mini pour afficher un montant secondaire (attente / verrouillé)
class MiniMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const MiniMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextSeed(
                  title,
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextSeed(
            "${ComptabiliteCalculator.formatMontant(value)} FCFA",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
