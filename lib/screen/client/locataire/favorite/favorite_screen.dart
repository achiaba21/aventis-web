import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/card/saved_listing_card.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran Favoris du Locataire — V8.5 branché sur `FavoriteBloc` croisé
/// avec `AppartementBloc`.
///
/// Reproduit `SavedScreen` du proto : grid 2 colonnes de cards 1:1 avec
/// heart actif en top-right.
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
      // S'assurer aussi que les appartements sont chargés (croisement IDs)
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
          builder: (context, favState) {
            final favIds = _favoriteIdsFromState(favState);
            return BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, appState) {
                final all = AppartementToListingMapper.mapMany(
                    appState.appartements);
                final favorites = all
                    .where((l) => favIds.contains(int.tryParse(l.id) ?? -1))
                    .toList();

                final isInitialLoading = favState is FavoriteLoading &&
                    favIds.isEmpty &&
                    all.isEmpty;
                if (isInitialLoading) return _buildLoading();

                if (favorites.isEmpty) {
                  return EmptyState.hero(
                    icon: Icons.favorite_border,
                    title: 'Aucun favori',
                    body:
                        'Tap sur le ♡ d\'un logement pour le sauvegarder ici.',
                  );
                }

                return _buildGrid(favorites);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(height: 220),
    );
  }

  Widget _buildGrid(List<ListingPreview> favorites) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: favorites.length,
      itemBuilder: (_, i) => SavedListingCard(
        listing: favorites[i],
        onTap: () => pushScreen(
          context,
          LocataireDetailScreen(listing: favorites[i]),
        ),
      ),
    );
  }
}
