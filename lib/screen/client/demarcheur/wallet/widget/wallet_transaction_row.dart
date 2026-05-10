import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/commission_transaction.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Ligne d'historique du Wallet démarcheur.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurWallet` (lignes 518-538) :
/// badge carré 36 px (accent or si entrée, info bleu si sortie) avec icon
/// arrow up/down + label + sous-titre date · contexte + montant signé en
/// mono à droite (entrée = accent or, sortie = info bleu).
class WalletTransactionRow extends StatelessWidget {
  final CommissionTransaction transaction;
  final bool isLast;

  const WalletTransactionRow({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  bool get _isOut => transaction.type == TransactionType.withdrawalOut;

  Color get _badgeBg =>
      _isOut ? AppColors.infoLight : AppColors.accentSoft;

  Color get _badgeFg => _isOut ? AppColors.info : AppColors.accent;

  IconData get _icon =>
      _isOut ? Icons.arrow_upward : Icons.arrow_downward;

  String get _formattedAmount {
    final sign = _isOut ? '−' : '+';
    return '$sign${FcfaFormatter.compact(transaction.amount)}';
  }

  String get _formattedDate {
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final m = months[transaction.date.month - 1];
    return '${transaction.date.day} $m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 16, color: _badgeFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$_formattedDate · ${transaction.subtitle}',
                  style: AppTextStyles.small.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formattedAmount,
            style: AppTextStyles.mono(TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _badgeFg,
            )),
          ),
        ],
      ),
    );
  }
}
