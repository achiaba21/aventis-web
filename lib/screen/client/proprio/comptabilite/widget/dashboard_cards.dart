import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Dashboard cards affichant les métriques comptables
///
/// Reçoit des valeurs calculées (pas de dépendance à RapportComptable)
class DashboardCards extends StatelessWidget {
  final double chiffreAffaires;
  final double totalCharges;
  final double beneficeNet;
  final double margePourcent;
  final double tauxOccupation;
  final double prixMoyenAppartements;
  final int nombreReservations;
  final int nombreCharges;

  const DashboardCards({
    super.key,
    required this.chiffreAffaires,
    required this.totalCharges,
    required this.beneficeNet,
    required this.margePourcent,
    required this.tauxOccupation,
    required this.prixMoyenAppartements,
    required this.nombreReservations,
    required this.nombreCharges,
  });

  @override
  Widget build(BuildContext context) {
    final estBeneficiaire = beneficeNet > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          "Résumé financier",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),

        // Ligne principale : CA et Charges
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: "Chiffre d'affaires",
                value: chiffreAffaires,
                icon: Icons.trending_up,
                color: AppColors.success,
                subtitle: "$nombreReservations réservation(s)",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: "Charges",
                value: totalCharges,
                icon: Icons.trending_down,
                color: AppColors.error,
                subtitle: "$nombreCharges charge(s)",
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Bénéfice net (pleine largeur)
        _BeneficeCard(
          benefice: beneficeNet,
          marge: margePourcent,
          estBeneficiaire: estBeneficiaire,
        ),

        const SizedBox(height: 12),

        // Statistiques supplémentaires
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Taux d'occupation",
                value: "${tauxOccupation.toStringAsFixed(1)}%",
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: "Prix moy. appart.",
                value: formatMontantCompact(prixMoyenAppartements),
                icon: Icons.apartment,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card pour afficher une métrique (CA ou Charges)
class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextSeed(
                  title,
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          TextSeed(
            formatMontant(value),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          const SizedBox(height: 4),
          TextSeed(
            subtitle,
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

/// Card pour afficher le bénéfice net
class _BeneficeCard extends StatelessWidget {
  final double benefice;
  final double marge;
  final bool estBeneficiaire;

  const _BeneficeCard({
    required this.benefice,
    required this.marge,
    required this.estBeneficiaire,
  });

  @override
  Widget build(BuildContext context) {
    final icon = estBeneficiaire
        ? Icons.emoji_events
        : (benefice < 0 ? Icons.warning : Icons.horizontal_rule);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: estBeneficiaire
              ? [AppColors.success, AppColors.success]
              : benefice < 0
                  ? [AppColors.error, AppColors.error]
                  : [AppColors.surface, AppColors.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  estBeneficiaire ? "BÉNÉFICE NET" : (benefice < 0 ? "DÉFICIT" : "ÉQUILIBRE"),
                  fontSize: 12,
                  color: AppColors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 4),
                TextSeed(
                  formatMontant(benefice.abs()),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextSeed(
              "${marge.toStringAsFixed(1)}%",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card pour afficher une statistique simple
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  title,
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                TextSeed(
                  value,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
