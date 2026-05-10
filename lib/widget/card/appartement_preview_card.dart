import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/certified_badge.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/card/spec_chip.dart';
import 'package:asfar/widget/img/floating_heart_button.dart';
import 'package:asfar/widget/img/img_placeholder.dart';
import 'package:asfar/widget/img/photo_dots.dart';

/// Card de logement plein largeur — équivalent `ListingCard` du proto.
///
/// Image 16:10 + badges flottants (heart, certifié) + photo dots + body
/// avec titre, rating, lieu, beds/baths/wifi, prix/nuit + total nuits.
class AppartementPreviewCard extends StatelessWidget {
  final ListingPreview listing;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final bool liked;
  final int nights;

  const AppartementPreviewCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLikeTap,
    this.liked = false,
    this.nights = 3,
  });

  @override
  Widget build(BuildContext context) {
    final priceTotal = listing.price * nights;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ImgPh(tone: listing.tone, radius: 0),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FloatingHeartButton(
                        onTap: onLikeTap,
                        active: liked,
                      ),
                    ),
                    if (listing.superhost)
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: CertifiedBadge(),
                      ),
                    const Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: PhotoDots(active: 0, count: 4),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          listing.rating.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${listing.reviews})',
                          style: AppTextStyles.small.copyWith(
                              fontSize: 12, color: AppColors.text3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.area} · ${listing.city} · ${listing.surface} m²',
                      style: AppTextStyles.small,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SpecChip(
                            icon: Icons.bed_outlined,
                            label: '${listing.beds} ch.'),
                        const SizedBox(width: 12),
                        SpecChip(
                            icon: Icons.bathtub_outlined,
                            label: '${listing.baths} sdb.'),
                        const SizedBox(width: 12),
                        const SpecChip(icon: Icons.wifi, label: 'WiFi'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          FcfaFormatter.compact(listing.price),
                          style: AppTextStyles.mono(const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          )),
                        ),
                        Text(
                          ' / nuit',
                          style: AppTextStyles.small.copyWith(
                              fontSize: 13, color: AppColors.text3),
                        ),
                        const Spacer(),
                        Text(
                          '$nights nuits · ${FcfaFormatter.compact(priceTotal)}',
                          style: AppTextStyles.small.copyWith(fontSize: 12),
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
