import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/compte/transaction.dart';
import 'package:asfar/screen/client/proprio/compte/widget/transaction_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran d'historique complet des transactions
class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  String _selectedFilter = 'all'; // all, credit, debit

  @override
  void initState() {
    super.initState();
    // Charger toutes les transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompteBloc>().add(LoadTransactions());
    });
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    switch (_selectedFilter) {
      case 'credit':
        return transactions.where((t) => t.isCredit).toList();
      case 'debit':
        return transactions.where((t) => t.isDebit).toList();
      default:
        return transactions;
    }
  }

  Map<String, List<Transaction>> _groupByMonth(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      if (transaction.dateTransaction != null) {
        final key = DateFormat('MMMM yyyy', 'fr_FR')
            .format(transaction.dateTransaction!);
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(transaction);
      }
    }

    return grouped;
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
          "Historique",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          // Filtres
          _FilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),

          // Liste des transactions
          Expanded(
            child: BlocBuilder<CompteBloc, CompteState>(
              builder: (context, state) {
                if (state is CompteLoading) {
                  return const _LoadingView();
                }

                if (state is CompteLoaded) {
                  final filtered = _filterTransactions(state.transactions);

                  if (filtered.isEmpty) {
                    return const EmptyTransactionsList();
                  }

                  final grouped = _groupByMonth(filtered);

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CompteBloc>().add(LoadTransactions());
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(Espacement.paddingBloc),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final month = grouped.keys.elementAt(index);
                        final transactions = grouped[month]!;

                        return _MonthSection(
                          month: month,
                          transactions: transactions,
                        );
                      },
                    ),
                  );
                }

                return const EmptyTransactionsList();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglets de filtre
class _FilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _FilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _FilterChip(
            label: "Tous",
            isSelected: selectedFilter == 'all',
            onTap: () => onFilterChanged('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: "Crédits",
            isSelected: selectedFilter == 'credit',
            onTap: () => onFilterChanged('credit'),
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: "Débits",
            isSelected: selectedFilter == 'debit',
            onTap: () => onFilterChanged('debit'),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

/// Chip de filtre
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
          ),
        ),
        child: TextSeed(
          label,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.textOnAccent : AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Section regroupant les transactions par mois
class _MonthSection extends StatelessWidget {
  final String month;
  final List<Transaction> transactions;

  const _MonthSection({
    required this.month,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextSeed(
            month.toUpperCase(),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return TransactionItem(transaction: transactions[index]);
          },
        ),
        const SizedBox(height: 16),
      ],
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
      child: ListShimmer(itemCount: 8),
    );
  }
}
