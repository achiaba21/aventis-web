import 'package:flutter/material.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/photo_grid_item.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/photos_upload_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 3 du wizard — photos. Reproduit `proprietaire-extras.jsx::step 3`
/// (lignes 147-196) : card upload + grille 3 colonnes + badge couverture.
class StepPhotos extends StatelessWidget {
  final List<PhotoAppart> photos;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;

  const StepPhotos({
    super.key,
    required this.photos,
    required this.onPickPhotos,
    required this.onRemovePhoto,
  });

  static const _minPhotos = 3;

  @override
  Widget build(BuildContext context) {
    final int count = photos.length;
    final bool minReached = count >= _minPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ajoutez des photos', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Minimum 3 photos. La première sera la photo de couverture.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        PhotosUploadCard(onTap: onPickPhotos),
        if (count > 0) ...[
          const SizedBox(height: 14),
          _CountAndStatusRow(count: count, minReached: minReached),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: count,
            itemBuilder: (_, i) {
              final photo = photos[i];
              return PhotoGridItem(
                localPath: photo.path,
                tone: (i % 4) + 1,
                isCover: i == 0,
                onRemove: () => onRemovePhoto(i),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _CountAndStatusRow extends StatelessWidget {
  final int count;
  final bool minReached;

  const _CountAndStatusRow({
    required this.count,
    required this.minReached,
  });

  @override
  Widget build(BuildContext context) {
    final int remaining = (3 - count).clamp(0, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count photo${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''}',
          style: AppTextStyles.eyebrow,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: minReached
                ? AppColors.success.withValues(alpha: 0.14)
                : AppColors.warn.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            minReached ? '✓ Min. atteint' : '$remaining de plus',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: minReached ? AppColors.success : AppColors.warn,
            ),
          ),
        ),
      ],
    );
  }
}
