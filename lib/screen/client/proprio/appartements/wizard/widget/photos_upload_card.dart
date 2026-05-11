import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/container/dashed_border_container.dart';

/// Card "Téléverser depuis l'appareil" — étape 3 wizard V9.1.
///
/// Reproduit `proprietaire-extras.jsx::step 3` upload card (lignes 154-169) :
/// dashed border + cercle accentSoft avec icon + + label + sous-titre.
class PhotosUploadCard extends StatelessWidget {
  final VoidCallback onTap;

  const PhotosUploadCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: DashedBorderContainer(
          radius: AppRadii.md,
          strokeWidth: 1.5,
          dashLength: 5,
          gapLength: 4,
          color: AppColors.line,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 26,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Téléverser depuis l'appareil",
                  style: AppTextStyles.small.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'JPG, PNG, HEIC · max. 10 Mo / photo',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
