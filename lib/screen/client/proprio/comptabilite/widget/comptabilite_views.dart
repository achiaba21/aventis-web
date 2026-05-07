import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Vue de chargement pour la comptabilité
class ComptabiliteLoadingView extends StatelessWidget {
  const ComptabiliteLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ListShimmer(itemCount: 5),
    );
  }
}

/// Vue d'erreur pour la comptabilité
class ComptabiliteErrorView extends StatelessWidget {
  final String message;

  const ComptabiliteErrorView({super.key, required this.message});

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
            ),
            const SizedBox(height: 8),
            TextSeed(
              message,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ChargeBloc>().add(RefreshCharges());
              },
              child: TextSeed("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vue vide (état initial) pour la comptabilité
class ComptabiliteEmptyView extends StatelessWidget {
  const ComptabiliteEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: AppColors.textMuted),
            const SizedBox(height: 24),
            TextSeed(
              "Suivi financier",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 12),
            TextSeed(
              "Créez d'abord une résidence pour commencer à suivre vos finances",
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
