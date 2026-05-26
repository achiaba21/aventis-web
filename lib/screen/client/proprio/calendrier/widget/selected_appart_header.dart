import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Header affiché sous les chips dans `CalendarBookingsScreen`.
///
/// Thumbnail à gauche + nom + sous-ligne `commune · prix FCFA/n`.
class SelectedAppartHeader extends StatelessWidget {
  final Appartement appartement;

  const SelectedAppartHeader({super.key, required this.appartement});

  @override
  Widget build(BuildContext context) {
    final commune = appartement.areaName;
    final prix = appartement.priceAmount;
    final prixStr = '${FcfaFormatter.compact(prix)}/n';
    final subtitle =
        commune.isNotEmpty ? '$commune · $prixStr' : prixStr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          // `DomainImage` ne propage `width/height` qu'à `Image.network` —
          // le placeholder reçoit les contraintes du parent. On wrappe donc
          // dans un SizedBox externe pour borner le tout.
          SizedBox(
            width: 56,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: DomainImage(
                path: appartement.firstPhotoPath,
                width: 56,
                height: 56,
                placeholder: ImgPh(tone: appartement.tone),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appartement.titleSafe,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
