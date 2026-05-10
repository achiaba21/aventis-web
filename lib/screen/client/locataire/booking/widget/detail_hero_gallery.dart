import 'package:flutter/material.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/img/img_placeholder.dart';
import 'package:asfar/widget/img/photo_dots.dart';

/// Galerie hero du Detail logement.
///
/// Image 1:1 plein largeur (`ImgPh` du tone) + indicateurs photo animés
/// au bas (dot actif élargi à 24px) + compteur "n/total" en bas-droite.
class DetailHeroGallery extends StatelessWidget {
  final int tone;
  final int activePhoto;
  final int totalPhotos;
  final ValueChanged<int>? onDotTap;

  const DetailHeroGallery({
    super.key,
    required this.tone,
    this.activePhoto = 0,
    this.totalPhotos = 5,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: ImgPh(tone: tone, radius: 0),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: PhotoDots(
              active: activePhoto,
              count: totalPhotos,
              animated: true,
            ),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xB30A0A0B),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                '${activePhoto + 1} / $totalPhotos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
