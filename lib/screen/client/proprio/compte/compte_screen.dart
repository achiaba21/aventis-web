import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/compte/historique_screen.dart';
import 'package:asfar/screen/client/proprio/compte/widget/retrait_form.dart';
import 'package:asfar/screen/client/proprio/compte/widget/solde_card.dart';
import 'package:asfar/screen/client/proprio/compte/widget/transaction_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran principal du compte propriétaire
class CompteScreen extends StatefulWidget {
  const CompteScreen({super.key});

  @override
  State<CompteScreen> createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données du compte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompteBloc>().add(LoadCompte());
    });
  }

  void _showRetraitForm(double soldeDisponible) {
    RetraitForm.show(
      context: context,
      soldeDisponible: soldeDisponible,
      onConfirm: (montant) {
        context.read<CompteBloc>().add(DemanderRetrait(montant: montant));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextSeed(
          "Mon Compte",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          BlocBuilder<CompteBloc, CompteState>(
            builder: (context, state) {
              if (state is CompteLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: TextSeed(
                      state.compte.numero ?? '',
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CompteBloc, CompteState>(
        listener: (context, state) {
          if (state is RetraitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Demande de retrait envoyée : ${ComptabiliteCalculator.formatMontant(state.demande.montant ?? 0)} FCFA',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is CompteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CompteLoading) {
            return const _LoadingView();
          }

          if (state is CompteError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<CompteBloc>().add(LoadCompte()),
            );
          }

          if (state is CompteLoaded) {
            return _LoadedView(
              state: state,
              onRetrait: () => _showRetraitForm(state.compte.solde ?? 0),
              onVoirHistorique: () => pushScreen(context, const HistoriqueScreen()),
            );
          }

          // État initial - afficher chargement
          return const _LoadingView();
        },
      ),
    );
  }
}

/// Vue chargée avec les données
class _LoadedView extends StatelessWidget {
  final CompteLoaded state;
  final VoidCallback onRetrait;
  final VoidCallback onVoirHistorique;

  const _LoadedView({
    required this.state,
    required this.onRetrait,
    required this.onVoirHistorique,
  });

  @override
  Widget build(BuildContext context) {
    final compte = state.compte;
    final transactions = state.transactions;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CompteBloc>().add(RefreshCompte());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espacement.paddingBloc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner compte suspendu
            if (compte.actif == false) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextSeed(
                        "Votre compte est suspendu. Les retraits sont désactivés.",
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Carte solde disponible
            SoldeCard(
              soldeDisponible: compte.solde ?? 0,
              compteActif: compte.actif ?? true,
              onRetrait: onRetrait,
            ),

            const SizedBox(height: 16),

            // Cartes secondaires (En attente / Verrouillé)
            Row(
              children: [
                Expanded(
                  child: MiniMetricCard(
                    title: "En attente",
                    value: compte.soldeAttente,
                    icon: Icons.hourglass_empty,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniMetricCard(
                    title: "Verrouillé",
                    value: compte.montantVerrouille,
                    icon: Icons.lock_outline,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section transactions récentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSeed(
                  "Transactions récentes",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                TextButton(
                  onPressed: onVoirHistorique,
                  child: TextSeed(
                    "Voir tout",
                    fontSize: 14,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Liste des transactions
            if (transactions.isEmpty)
              const EmptyTransactionsList()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return TransactionItem(transaction: transactions[index]);
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Vue de chargement
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ListShimmer(itemCount: 4),
    );
  }
}

/// Vue d'erreur
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            TextSeed(
              "Erreur de chargement",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            TextSeed(
              message,
              textAlign: TextAlign.center,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: TextSeed("Réessayer", color: AppColors.textOnAccent),
            ),
          ],
        ),
      ),
    );
  }
}
