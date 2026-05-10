import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/certified_badge.dart';
import 'package:asfar/widget/badge/rating_chip.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/floating_heart_button.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card "À la une" du Home Locataire — 220px de large, ratio 4:5.
///
/// Reproduit le carrousel horizontal de `LocataireHome` : badge rating
/// top-left, heart top-right, badge "★ Hôte certifié" bottom-left.
/// Body sous l'image : titre, lieu, prix/nuit.
class FeaturedListingCard extends StatelessWidget {
  final ListingPreview listing;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool liked;
  final double width;

  const FeaturedListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLikeTap,
    this.liked = false,
    this.width = 220,
  });

  /// Format `area · city` en gérant les valeurs vides (vraies données peuvent
  /// avoir address null ou commune partielle).
  String _locationText() {
    final parts = [listing.area, listing.city]
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
                      child: ImgPh(tone: listing.tone, radius: 18),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: RatingChip(rating: listing.rating),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FloatingHeartButton(
                        onTap: onLikeTap,
                        active: liked,
                        size: 32,
                      ),
                    ),
                    if (listing.superhost)
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
                      listing.title,
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
                          FcfaFormatter.compact(listing.price),
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
