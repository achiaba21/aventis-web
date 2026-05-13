import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/img/img_placeholder.dart';
import 'package:asfar/widget/img/photo_carousel.dart';

/// Hero photo du `ProprioListingEditScreen`.
///
/// Carrousel swipeable de toutes les photos backend (cohérent avec le
/// `LocataireDetailScreen`). Le badge bottom-right reflète le nombre
/// réel de photos en base. Dots animés en bas pour indiquer la position.
class ListingEditHero extends StatelessWidget {
  final Appartement appartement;

  const ListingEditHero({super.key, required this.appartement});

  List<String?> get _paths {
    final list = appartement.photos ?? const [];
    return list.map((p) => p.path).toList();
  }

  int get _photoCount =>
      _paths.where((p) => p != null && p.trim().isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoCarousel(
              paths: _paths,
              placeholder: ImgPh(tone: appartement.tone, radius: 0),
              showCounter: false,
            ),
          ),
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
                    _photoCount == 0
                        ? 'Aucune photo'
                        : '$_photoCount photo${_photoCount > 1 ? 's' : ''}',
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
