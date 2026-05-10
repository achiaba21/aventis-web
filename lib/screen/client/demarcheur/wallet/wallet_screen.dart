import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/sample/sample_commissions.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_solde_card.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_transaction_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';

/// Écran « Mes commissions » du Démarcheur — onglet Wallet.
///
/// Reproduit `DemarcheurWallet` du prototype : `WalletSoldeCard` (gradient
/// 2 stops + bouton « Retirer maintenant ») + section « Historique » avec
/// liste de `WalletTransactionRow`.
///
/// Le bouton « Retirer maintenant » ouvre un SnackBar stub — la vraie UX
/// retrait est définie en F9 (Banque/Cartes/Compte) selon `ui-proposal.md`.
class DemarcheurWalletScreen extends StatelessWidget {
  const DemarcheurWalletScreen({super.key});

  void _onWithdraw(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrait disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = SampleCommissions.all;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Mes commissions'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletSoldeCard(
                amount: 164000,
                onWithdraw: () => _onWithdraw(context),
              ),
              const SizedBox(height: 22),
              const Text('Historique', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
