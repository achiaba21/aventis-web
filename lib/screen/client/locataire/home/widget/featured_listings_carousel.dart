import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/card/featured_listing_card.dart';

/// Carrousel horizontal "À la une" du `LocataireHomeScreen` — 3 premiers
/// appartements en `FeaturedListingCard`.
///
/// Le statut favori est géré PAR CARTE via `FavoriteToggleButton`
/// (BlocSelector) : un like ne reconstruit plus le carrousel (PERF-03).
class FeaturedListingsCarousel extends StatelessWidget {
  final List<Appartement> appartements;
  final void Function(Appartement appartement)? onTap;

  const FeaturedListingsCarousel({
    super.key,
    required this.appartements,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: appartements.take(3).length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final a = appartements[i];
          return FeaturedListingCard(
            appartement: a,
            onTap: onTap == null ? null : () => onTap!(a),
          );
        },
      ),
    );
  }
}
