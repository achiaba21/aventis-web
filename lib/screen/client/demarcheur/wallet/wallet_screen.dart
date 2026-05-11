import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_history_card.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_loading_view.dart';
import 'package:asfar/screen/client/demarcheur/wallet/widget/wallet_solde_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Mes commissions » du Démarcheur — onglet Wallet.
///
/// Branché sur `CompteBloc`. Le solde provient de `state.compte.solde` et
/// l'historique de `state.transactions` (modèle métier `Transaction`)
/// consommé directement par `WalletHistoryCard`.
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

  void _onWithdraw() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrait disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  CompteLoaded? _extractLoaded(CompteState state) {
    if (state is CompteLoaded) return state;
    if (state is RetraitSuccess) return state.previousState;
    return null;
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
            if (state is CompteLoading) return const WalletLoadingView();
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
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WalletSoldeCard(
                    amount: solde,
                    onWithdraw: _onWithdraw,
                  ),
                  const SizedBox(height: 22),
                  const Text('Historique', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    EmptyState.inline(
                      icon: Icons.history_outlined,
                      title: 'Pas encore de mouvement',
                      body: 'Vos commissions et retraits apparaîtront ici.',
                    )
                  else
                    WalletHistoryCard(transactions: transactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
