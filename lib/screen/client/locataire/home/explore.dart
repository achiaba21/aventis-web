import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/screen/client/locataire/home/widget/explore_appartements_list.dart';
import 'package:asfar/screen/client/locataire/map/map_explore_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/dialog/open_dialog.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_app_bar.dart';
import 'package:asfar/widget/bottom_dialogue/filter_option.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/input/input_search.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DynamicAppBar(title: "Explorer", showBackButton: false),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
            children: [
              BlocBuilder<AppartementBloc, AppartementState>(
                builder: (context, state) {
                  final filteredState = state is FilteredAppartementsLoaded ? state : null;
                  final hasFilters = filteredState != null && filteredState.criteria.hasFilters;
                  final filterCount = hasFilters ? filteredState.criteria.activeFiltersCount : 0;

                  return Column(
                    children: [
                      // Recherche + bouton carte sur une ligne
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  InputSearch(onPressed: () => opPenFilter(context)),
                                  if (hasFilters)
                                    Positioned(
                                      right: 48,
                                      top: 12,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '$filterCount',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.accent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  pushScreen(context, MapExploreScreen());
                                },
                                icon: Icon(Icons.map_outlined),
                                color: AppColors.accent,
                                tooltip: "Vue carte",
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasFilters)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              TextSeed(
                                "Filtres actifs ($filterCount)",
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              Spacer(),
                              PlainButton(
                                value: "Effacer",
                                plain: false,
                                onPress: () {
                                  context.read<AppartementBloc>().add(ClearFilters());
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<AppartementBloc, AppartementState>(
                  builder: (context, state) {
                    // Afficher skeleton pendant le chargement initial (préchargement en cours)
                    if (state is AppartementInitial) {
                      return const AppartementListShimmer(itemCount: 5);
                    }
                    // Afficher skeleton pendant un rechargement manuel (cohérence UX)
                    else if (state is AppartementLoading) {
                      return const AppartementListShimmer(itemCount: 5);
                    } else if (state is AppartementLoaded) {
                      return ExploreAppartementsList(
                        appartements: state.appartements,
                      );
                    } else if (state is FilteredAppartementsLoaded) {
                      return ExploreAppartementsList(
                        appartements: state.appartements,
                        criteria: state.criteria,
                      );
                    } else if (state is FilterOptionsLoaded) {
                      if (state.appartements != null) {
                        return ExploreAppartementsList(
                          appartements: state.appartements!,
                        );
                      }
                      return const AppartementListShimmer(itemCount: 5);
                    } else if (state is AppartementError) {
                      return ExploreErrorState(
                        message: state.message,
                        onRetry: () {
                          final appartBloc = context.read<AppartementBloc>();
                          final currentState = appartBloc.state;
                          if (currentState is FilteredAppartementsLoaded) {
                            appartBloc.add(LoadFilteredAppartements(currentState.criteria));
                          } else {
                            appartBloc.add(LoadAppartements());
                          }
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
            ),
          ),
      ),
    );
  }

  void opPenFilter(BuildContext context) {
    final appartBloc = context.read<AppartementBloc>();
    final currentState = appartBloc.state;
    final currentCriteria = currentState is FilteredAppartementsLoaded ? currentState.criteria : null;

    dialogBottomSheet(
      context,
      FilterOption(
        initialCriteria: currentCriteria,
      ),
      hide: true,
    );
  }
}
