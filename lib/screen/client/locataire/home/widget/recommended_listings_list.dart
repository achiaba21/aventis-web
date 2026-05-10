import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Liste verticale "Recommandés pour vous" du `LocataireHomeScreen` —
/// `AppartementPreviewCard` avec `BlocBuilder` sur `FavoriteBloc` pour
/// le heart.
class RecommendedListingsList extends StatelessWidget {
  final List<ListingPreview> listings;
  final void Function(ListingPreview listing)? onTap;
  final void Function(ListingPreview listing)? onLikeTap;

  const RecommendedListingsList({
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
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favState) {
        final favIds = _favoriteIdsFromState(favState);
        return Column(
          children: [
            for (var i = 0; i < listings.length; i++) ...[
              AppartementPreviewCard(
                listing: listings[i],
                liked: _isLiked(favIds, listings[i]),
                onTap: onTap == null ? null : () => onTap!(listings[i]),
                onLikeTap:
                    onLikeTap == null ? null : () => onLikeTap!(listings[i]),
              ),
              if (i != listings.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
