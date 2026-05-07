import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Liste des appartements avec RefreshIndicator pour l'exploration
class ExploreAppartementsList extends StatelessWidget {
  final List<Appartement> appartements;
  final FilterCriteria? criteria;

  const ExploreAppartementsList({
    super.key,
    required this.appartements,
    this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppartementBloc>();

    if (appartements.isEmpty) {
      return ExploreEmptyState(
        criteria: criteria,
        onRefresh: () => _refresh(bloc),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(bloc),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (criteria != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextSeed(
                  "${appartements.length} résultat${appartements.length > 1 ? 's' : ''} trouvé${appartements.length > 1 ? 's' : ''}",
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ...appartements.map((e) => AppartItem(e)),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh(AppartementBloc bloc) async {
    if (criteria != null) {
      bloc.add(LoadFilteredAppartements(criteria!));
    } else {
      bloc.add(RefreshAppartements());
    }
    await bloc.stream.firstWhere(
      (state) =>
          state is AppartementLoaded ||
          state is FilteredAppartementsLoaded ||
          state is AppartementError,
      orElse: () => bloc.state,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => bloc.state,
    );
  }
}

/// État vide pour l'exploration
class ExploreEmptyState extends StatelessWidget {
  final FilterCriteria? criteria;
  final Future<void> Function() onRefresh;

  const ExploreEmptyState({
    super.key,
    this.criteria,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 24),
                    TextSeed(
                      criteria != null
                          ? "Aucun résultat pour ces filtres"
                          : "Aucun appartement disponible",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    TextSeed(
                      criteria != null
                          ? "Essayez de modifier vos critères de recherche"
                          : "Aucun appartement n'est disponible pour le moment",
                      textAlign: TextAlign.center,
                      color: AppColors.textSecondary,
                    ),
                    if (criteria != null) ...[
                      const SizedBox(height: 32),
                      PlainButton(
                        value: "Effacer les filtres",
                        onPress: () {
                          context.read<AppartementBloc>().add(ClearFilters());
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// État d'erreur pour l'exploration
class ExploreErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ExploreErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            PlainButton(
              value: "Réessayer",
              onPress: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
