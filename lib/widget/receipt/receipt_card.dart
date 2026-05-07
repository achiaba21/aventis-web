import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Carte de résumé d'un reçu
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
    this.compact = false,
  });

  final Receipt receipt;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Espacement.radius),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec type et numéro
            Row(
              children: [
                _ReceiptTypeBadge(type: receipt.typeRecu),
                const Spacer(),
                if (receipt.numeroRecu != null)
                  TextSeed(
                    receipt.numeroRecu!,
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
              ],
            ),

            SizedBox(height: compact ? 8 : 12),

            // Montant versé
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Montant versé",
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 2),
                    TextSeed(
                      "${helpAmountFormate((receipt.montantVerse ?? 0).toInt(), decim: false)} ${receipt.devise ?? 'FCFA'}",
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                const Spacer(),
                if (!compact && receipt.montantTotal != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextSeed(
                        "sur ${helpAmountFormate(receipt.montantTotal!.toInt(), decim: false)}",
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      _PaymentProgress(receipt: receipt),
                    ],
                  ),
                ],
              ],
            ),

            // Détails supplémentaires (mode non compact)
            if (!compact) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.surface, height: 1),
              const SizedBox(height: 12),

              // Date d'émission et moyen de paiement
              Row(
                children: [
                  if (receipt.dateEmission != null) ...[
                    Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    TextSeed(
                      _formatDate(receipt.dateEmission!),
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ],
                  const Spacer(),
                  if (receipt.moyenPaiement != null) ...[
                    Icon(Icons.payment, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    TextSeed(
                      receipt.moyenPaiement!,
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ],

            // Indicateur de navigation
            if (onTap != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextSeed(
                    "Voir le détail",
                    fontSize: 12,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (receipt.typeRecu == ReceiptType.definitif) {
      return AppColors.success.withValues(alpha: 0.3);
    }
    return AppColors.accent.withValues(alpha: 0.3);
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

/// Badge du type de reçu
class _ReceiptTypeBadge extends StatelessWidget {
  const _ReceiptTypeBadge({required this.type});

  final ReceiptType type;

  @override
  Widget build(BuildContext context) {
    final isDefinitif = type == ReceiptType.definitif;
    final color = isDefinitif ? AppColors.success : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDefinitif ? Icons.check_circle : Icons.hourglass_bottom,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          TextSeed(
            type.label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// Indicateur de progression du paiement
class _PaymentProgress extends StatelessWidget {
  const _PaymentProgress({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final percentage = receipt.pourcentagePaye;
    final isComplete = receipt.isPaidInFull;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppColors.success : AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        TextSeed(
          "${percentage.toStringAsFixed(0)}%",
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isComplete ? AppColors.success : AppColors.accent,
        ),
      ],
    );
  }
}

/// Widget pour afficher la section d'une facture dans le détail de réservation
class SingleReceiptSection extends StatelessWidget {
  const SingleReceiptSection({
    super.key,
    required this.receipt,
    this.onReceiptTap,
  });

  final Receipt receipt;
  final Function(Receipt)? onReceiptTap;

  @override
  Widget build(BuildContext context) {
    return ReceiptCard(
      receipt: receipt,
      onTap: onReceiptTap != null ? () => onReceiptTap!(receipt) : null,
    );
  }
}

/// Widget pour afficher la section des reçus dans le détail de réservation
class ReceiptSection extends StatelessWidget {
  const ReceiptSection({
    super.key,
    required this.receipts,
    this.onReceiptTap,
  });

  final List<Receipt> receipts;
  final Function(Receipt)? onReceiptTap;

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return _EmptyReceiptsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < receipts.length; i++) ...[
          ReceiptCard(
            receipt: receipts[i],
            onTap: onReceiptTap != null ? () => onReceiptTap!(receipts[i]) : null,
          ),
          if (i < receipts.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// État vide pour les reçus
class _EmptyReceiptsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Espacement.radius),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          TextSeed(
            "Aucun reçu disponible",
            fontSize: 14,
            color: AppColors.textMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextSeed(
            "Les reçus seront générés après le paiement",
            fontSize: 12,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
