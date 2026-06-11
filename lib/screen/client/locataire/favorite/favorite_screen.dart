import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/favorite/widget/favorites_grid.dart';
import 'package:asfar/screen/client/locataire/favorite/widget/favorites_loading_grid.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran Favoris du Locataire — branché sur `FavoriteBloc` croisé
/// avec `AppartementBloc`. Consomme directement `Appartement`.
class LocataireFavoriteScreen extends StatefulWidget {
  const LocataireFavoriteScreen({super.key});

  @override
  State<LocataireFavoriteScreen> createState() =>
      _LocataireFavoriteScreenState();
}

class _LocataireFavoriteScreenState extends State<LocataireFavoriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final favBloc = context.read<FavoriteBloc>();
      if (favBloc.state is! FavoriteLoaded) {
        favBloc.add(LoadFavorites());
      }
      final appBloc = context.read<AppartementBloc>();
      if (appBloc.state.appartements.isEmpty) {
        appBloc.add(LoadAppartements());
      }
    });
  }

  List<int> _favoriteIdsFromState(FavoriteState state) {
    if (state is FavoriteLoaded) return state.favoriteIds;
    if (state is FavoriteOptimisticUpdate) return state.favoriteIds;
    if (state is FavoriteActionSuccess) return state.favoriteIds;
    if (state is FavoriteError) return state.favoriteIds ?? const [];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Favoris'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<FavoriteBloc, FavoriteState>(
          // PERF-03 : ne rebuild la grille que si la liste d'ids change
          // (ou en phase de chargement initial), pas sur les états
          // transitoires (succès/erreur) porteurs des mêmes ids.
          buildWhen: (previous, current) =>
              previous is FavoriteLoading ||
              current is FavoriteLoading ||
              !listEquals(
                _favoriteIdsFromState(previous),
                _favoriteIdsFromState(current),
              ),
          builder: (context, favState) {
            final favIds = _favoriteIdsFromState(favState);
            return BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, appState) {
                final all = appState.appartements;
                final favorites = all
                    .where((a) => a.id != null && favIds.contains(a.id))
                    .toList(growable: false);

                final isInitialLoading = favState is FavoriteLoading &&
                    favIds.isEmpty &&
                    all.isEmpty;
                if (isInitialLoading) return const FavoritesLoadingGrid();

                if (favorites.isEmpty) {
                  return EmptyState.hero(
                    icon: Icons.favorite_border,
                    title: 'Aucun favori',
                    body:
                        'Tap sur le ♡ d\'un logement pour le sauvegarder ici.',
                  );
                }

                return FavoritesGrid(
                  favorites: favorites,
                  onTap: (appartement) => pushScreen(
                    context,
                    LocataireDetailScreen(appartement: appartement),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
