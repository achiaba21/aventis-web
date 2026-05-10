import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/widget/card/featured_listing_card.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Carrousel horizontal "À la une" du `LocataireHomeScreen` — 3 premiers
/// listings en `FeaturedListingCard`, branché sur `FavoriteBloc` pour le
/// heart.
class FeaturedListingsCarousel extends StatelessWidget {
  final List<ListingPreview> listings;
  final void Function(ListingPreview listing)? onTap;
  final void Function(ListingPreview listing)? onLikeTap;

  const FeaturedListingsCarousel({
    super.key,
    required this.listings,
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

  static bool _isLiked(List<int> ids, ListingPreview listing) {
    final apartId = int.tryParse(listing.id);
    return apartId != null && ids.contains(apartId);
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
            itemCount: listings.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final l = listings[i];
              return FeaturedListingCard(
                listing: l,
                liked: _isLiked(favIds, l),
                onTap: onTap == null ? null : () => onTap!(l),
                onLikeTap: onLikeTap == null ? null : () => onLikeTap!(l),
              );
            },
          );
        },
      ),
    );
  }
}
