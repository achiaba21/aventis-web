import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/card/featured_listing_card.dart';

/// Carrousel horizontal "À la une" du `LocataireHomeScreen` — 3 premiers
/// appartements en `FeaturedListingCard`, branché sur `FavoriteBloc` pour le
/// heart.
class FeaturedListingsCarousel extends StatelessWidget {
  final List<Appartement> appartements;
  final void Function(Appartement appartement)? onTap;
  final void Function(Appartement appartement)? onLikeTap;

  const FeaturedListingsCarousel({
    super.key,
    required this.appartements,
    this.onTap,
    this.onLikeTap,
  });

  static List<int> _favoriteIdsFromState(FavoriteState state) {
    if (state is FavoriteLoaded) return state.favoriteIds;
    if (state is FavoriteOptimisticUpdate) return state.favoriteIds;
    if (state is FavoriteActionSuccess) return state.favoriteIds;
    if (state is FavoriteError) return state.favoriteIds ?? const [];
    return const [];
  }

  static bool _isLiked(List<int> ids, Appartement appart) {
    final id = appart.id;
    return id != null && ids.contains(id);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, favState) {
          final favIds = _favoriteIdsFromState(favState);
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: appartements.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final a = appartements[i];
              return FeaturedListingCard(
                appartement: a,
                liked: _isLiked(favIds, a),
                onTap: onTap == null ? null : () => onTap!(a),
                onLikeTap: onLikeTap == null ? null : () => onLikeTap!(a),
              );
            },
          );
        },
      ),
    );
  }
}
