import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Hero photo du `ProprioListingEditScreen`.
///
/// Affiche la 1re photo backend (`appartement.photos[0].path`) si dispo,
/// fallback `ImgPh(tone)` sinon. Le badge bottom-right reflète le nombre
/// réel de photos en base.
class ListingEditHero extends StatelessWidget {
  final Appartement appartement;

  const ListingEditHero({super.key, required this.appartement});

  int get _photoCount {
    final list = appartement.photos ?? const [];
    return list.where((p) => (p.path ?? '').isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    final url = appartement.firstPhotoPath;
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(
            child: DomainImage(
              path: url,
              placeholder: ImgPh(tone: appartement.tone, radius: 0),
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
