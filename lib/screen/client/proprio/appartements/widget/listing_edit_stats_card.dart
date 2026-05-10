import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_stats_occupancy_col.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_stats_rating_col.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Card stats compacte du `ProprioListingEditScreen` — affichée juste après
/// le Hero photo.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 481-502) : Row 2 cols séparée par un `Container 1×_` line.
class ListingEditStatsCard extends StatelessWidget {
  final ListingPreview listing;
  final double occupancyRate;

  const ListingEditStatsCard({
    super.key,
    required this.listing,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: ListingStatsOccupancyCol(occupancyRate: occupancyRate),
            ),
            Container(width: 1, color: AppColors.line),
            const SizedBox(width: 16),
            Expanded(
              child: ListingStatsRatingCol(
                rating: listing.rating,
                reviews: listing.reviews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
