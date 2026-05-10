import 'package:flutter/material.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/card/saved_listing_card.dart';

/// Grid 2 colonnes de `SavedListingCard` pour `LocataireFavoriteScreen`.
class FavoritesGrid extends StatelessWidget {
  final List<ListingPreview> favorites;
  final void Function(ListingPreview listing)? onTap;

  const FavoritesGrid({
    super.key,
    required this.favorites,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap == null ? null : () => onTap!(favorites[i]),
      ),
    );
  }
}
