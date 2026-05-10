import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/commission_transaction.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_transaction_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card historique des transactions du wallet démarcheur (encadré liste).
class WalletHistoryCard extends StatelessWidget {
  final List<CommissionTransaction> transactions;

  const WalletHistoryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++)
            WalletTransactionRow(
              transaction: transactions[i],
              isLast: i == transactions.length - 1,
            ),
        ],
      ),
    );
  }
}
