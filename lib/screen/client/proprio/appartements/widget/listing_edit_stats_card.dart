import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_stats_likes_col.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_stats_occupancy_col.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_stats_rating_col.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card stats compacte du `ProprioListingEditScreen` — affichée juste après
/// le Hero photo. 3 colonnes : occupation (mois courant) / note moy. / favoris.
class ListingEditStatsCard extends StatelessWidget {
  final Appartement appartement;
  final double occupancyRate;

  const ListingEditStatsCard({
    super.key,
    required this.appartement,
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
            const SizedBox(width: 12),
            Expanded(
              child: ListingStatsRatingCol(
                rating: appartement.rating,
                reviews: appartement.reviewsCount,
              ),
            ),
            Container(width: 1, color: AppColors.line),
            const SizedBox(width: 12),
            Expanded(
              child: ListingStatsLikesCol(likes: appartement.likes ?? 0),
            ),
          ],
        ),
      ),
    );
  }
}
