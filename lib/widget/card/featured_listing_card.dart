import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/certified_badge.dart';
import 'package:asfar/widget/badge/rating_chip.dart';
import 'package:asfar/widget/button/favorite_toggle_button.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card "À la une" du Home Locataire — 220px de large, ratio 4:5.
///
/// Consomme directement le modèle métier [Appartement] via l'extension
/// `AppartementDisplay`. Reproduit le carrousel horizontal de `LocataireHome`.
class FeaturedListingCard extends StatelessWidget {
  final Appartement appartement;
  final VoidCallback? onTap;
  final double width;

  const FeaturedListingCard({
    super.key,
    required this.appartement,
    this.onTap,
    this.width = 220,
  });

  String _locationText() {
    final parts = [appartement.areaName, appartement.cityName]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DomainImage(
                        path: appartement.firstPhotoPath,
                        placeholder:
                            ImgPh(tone: appartement.tone, radius: 18),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: RatingChip(rating: appartement.rating),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FavoriteToggleButton(
                        appartementId: appartement.id,
                        size: 32,
                      ),
                    ),
                    if (appartement.isSuperhost)
                      const Positioned(
                        bottom: 10,
                        left: 10,
                        child: CertifiedBadge(
                          variant: CertifiedBadgeVariant.solid,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appartement.titleSafe,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationText(),
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          FcfaFormatter.compact(appartement.priceAmount),
                          style: AppTextStyles.mono(const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          )),
                        ),
                        Text(
                          ' / nuit',
                          style: AppTextStyles.small.copyWith(
                              fontSize: 12, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
