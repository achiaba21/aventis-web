import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `LocataireFavoriteScreen` — grid 2 cols, 4 cards
/// pendant le chargement initial.
class FavoritesLoadingGrid extends StatelessWidget {
  const FavoritesLoadingGrid({super.key});

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
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(height: 220),
    );
  }
}
