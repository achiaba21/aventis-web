import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Hero photo du `ProprioListingEditScreen`.
///
/// Consomme directement [Appartement]. Reproduit le proto
/// `proprietaire.jsx::ProprietaireListingEdit` (lignes 468-477) : `ImgPh`
/// ratio 16:10 + badge en bottom-right blur 10 avec icon image + nb photos.
class ListingEditHero extends StatelessWidget {
  final Appartement appartement;
  final int photoCount;

  const ListingEditHero({
    super.key,
    required this.appartement,
    this.photoCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(child: ImgPh(tone: appartement.tone, radius: 0)),
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
