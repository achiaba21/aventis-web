import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Hero photo du `ProprioListingEditScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 468-477) : `ImgPh` ratio 16:10 + badge en bottom-right
/// (`rgba(10,10,11,0.7)` blur 10) avec icon image + texte « 8 photos ».
class ListingEditHero extends StatelessWidget {
  final ListingPreview listing;
  final int photoCount;

  const ListingEditHero({
    super.key,
    required this.listing,
    this.photoCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(child: ImgPh(tone: listing.tone, radius: 0)),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '$photoCount photos',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
