import 'package:flutter/material.dart';
import 'package:asfar/model/compte/transaction.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Widget pour afficher une transaction dans une liste
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final prefix = isCredit ? '+' : '-';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Description et date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    transaction.description ?? 'Transaction',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  TextSeed(
                    formatDateMonth(transaction.dateTransaction),
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            // Montant
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextSeed(
                  '$prefix${ComptabiliteCalculator.formatMontant((transaction.montant ?? 0).abs())} FCFA',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                if (transaction.isEnAttente)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextSeed(
                      "En attente",
                      fontSize: 10,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher une liste vide de transactions
class EmptyTransactionsList extends StatelessWidget {
  const EmptyTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            TextSeed(
              "Aucune transaction",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            TextSeed(
              "Vos transactions apparaîtront ici",
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
