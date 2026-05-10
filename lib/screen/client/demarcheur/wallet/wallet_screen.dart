import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_solde_card.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_transaction_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/mapping/transaction_to_commission.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran « Mes commissions » du Démarcheur — onglet Wallet.
///
/// V8.5 Lot 8c : branché sur `CompteBloc`. Le solde provient de
/// `state.compte.solde` et l'historique de `state.transactions` mappé via
/// `TransactionToCommissionMapper`. Plus aucun mock `SampleCommissions`.
class DemarcheurWalletScreen extends StatefulWidget {
  const DemarcheurWalletScreen({super.key});

  @override
  State<DemarcheurWalletScreen> createState() => _DemarcheurWalletScreenState();
}

class _DemarcheurWalletScreenState extends State<DemarcheurWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CompteBloc>().add(LoadCompte());
    });
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Mes commissions'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<CompteBloc, CompteState>(
          builder: (context, state) {
            if (state is CompteLoading) return _buildLoading();
            if (state is CompteError) {
              return EmptyState.error(
                message: state.message,
                onRetry: () =>
                    context.read<CompteBloc>().add(RefreshCompte()),
              );
            }
            final loaded = _extractLoaded(state);
            final solde = (loaded?.compte.solde ?? 0).round();
            final transactions = loaded?.transactions ?? const [];
            final commissions =
                TransactionToCommissionMapper.mapMany(transactions);
            return _buildContent(context, solde, commissions);
          },
        ),
      ),
    );
  }

  CompteLoaded? _extractLoaded(CompteState state) {
    if (state is CompteLoaded) return state;
    if (state is RetraitSuccess) return state.previousState;
    return null;
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: const [
        ShimmerCard(height: 180),
        SizedBox(height: 22),
        ShimmerCard(height: 64),
        SizedBox(height: 10),
        ShimmerCard(height: 64),
        SizedBox(height: 10),
        ShimmerCard(height: 64),
      ],
    );
  }

  Widget _buildContent(BuildContext context, int solde, List commissions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WalletSoldeCard(
            amount: solde,
            onWithdraw: () => _onWithdraw(context),
          ),
          const SizedBox(height: 22),
          const Text('Historique', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          if (commissions.isEmpty)
            EmptyState.inline(
              icon: Icons.history_outlined,
              title: 'Pas encore de mouvement',
              body: 'Vos commissions et retraits apparaîtront ici.',
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgElev1,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.line, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < commissions.length; i++)
                    WalletTransactionRow(
                      transaction: commissions[i],
                      isLast: i == commissions.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
