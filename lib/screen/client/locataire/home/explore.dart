import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_state.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_item.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/dialog/open_dialog.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/widget/bottom_dialogue/filter_option.dart';
import 'package:web_flutter/widget/input/input_search.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';
import 'package:web_flutter/screen/client/locataire/map/map_explore_screen.dart';

class Explore extends StatelessWidget {
  static final routeName = "/explore";
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    deboger(["state :", userState]);
    if (userState is UserLoaded) {
      deboger(userState.user);
    }

    return SafeArea(
      child: BlocListener<AppartementBloc, AppartementState>(
        listenWhen: (previous, current) => previous is AppartementInitial,
        listener: (context, state) {
          if (state is AppartementInitial) {
            context.read<AppartementBloc>().add(LoadAppartements());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Consumer<AppData>(
                builder: (context, appData, child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Stack(
                          children: [
                            InputSearch(onPressed: () => opPenFilter(context)),
                            if (appData.hasActiveFilters)
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '${appData.activeFiltersCount}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: PlainButton(
                                value: "Vue carte",
                                plain: false,
                                onPress: () {
                                  Navigator.pushNamed(context, MapExploreScreen.routeName);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (appData.hasActiveFilters)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              TextSeed(
                                "Filtres actifs (${appData.activeFiltersCount})",
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              Spacer(),
                              PlainButton(
                                value: "Effacer",
                                plain: false,
                                onPress: () {
                                  appData.clearFilters();
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
                    if (state is AppartementInitial) {
                      context.read<AppartementBloc>().add(LoadAppartements());
                      return const Center(child: CircularProgress());
                    } else if (state is AppartementLoading) {
                      return const Center(child: CircularProgress());
                    } else if (state is AppartementLoaded) {
                      return _buildAppartementsList(state.appartements, null);
                    } else if (state is FilteredAppartementsLoaded) {
                      return _buildAppartementsList(state.appartements, state.criteria);
                    } else if (state is FilterOptionsLoaded) {
                      if (state.appartements != null) {
                        return _buildAppartementsList(state.appartements!, null);
                      }
                      return const Center(child: CircularProgress());
                    } else if (state is AppartementError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 24),
                              TextSeed(
                                "Erreur de chargement",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 8),
                              TextSeed(
                                state.message,
                                textAlign: TextAlign.center,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 32),
                              PlainButton(
                                value: "Réessayer",
                                onPress: () {
                                  final appData = Provider.of<AppData>(context, listen: false);
                                  if (appData.hasActiveFilters) {
                                    // Réessayer avec les filtres actifs
                                    context.read<AppartementBloc>().add(
                                      LoadFilteredAppartements(appData.currentFilterCriteria!)
                                    );
                                  } else {
                                    // Réessayer sans filtres
                                    context.read<AppartementBloc>().add(LoadAppartements());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildAppartementsList(List<dynamic> appartements, dynamic criteria) {
    if (appartements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              SizedBox(height: 24),
              TextSeed(
                criteria != null ? "Aucun résultat pour ces filtres" : "Aucun appartement disponible",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8),
              TextSeed(
                criteria != null
                    ? "Essayez de modifier vos critères de recherche"
                    : "Aucun appartement n'est disponible pour le moment",
                textAlign: TextAlign.center,
                color: Colors.grey[600],
              ),
              if (criteria != null) ...[
                SizedBox(height: 32),
                Consumer<AppData>(
                  builder: (context, appData, child) {
                    return PlainButton(
                      value: "Effacer les filtres",
                      onPress: () {
                        appData.clearFilters();
                        context.read<AppartementBloc>().add(ClearFilters());
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (criteria != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextSeed(
                "${appartements.length} résultat${appartements.length > 1 ? 's' : ''} trouvé${appartements.length > 1 ? 's' : ''}",
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ...appartements.map((e) => AppartItem(e)),
        ],
      ),
    );
  }

  void opPenFilter(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);
    dialogBottomSheet(
      context,
      FilterOption(
        initialCriteria: appData.currentFilterCriteria,
      ),
      hide: true,
    );
  }
}
