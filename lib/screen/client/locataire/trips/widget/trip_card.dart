import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card horizontale de réservation (à venir / passée) dans `Trips`.
///
/// Image 110×110 gauche + content droite (badge statut, titre, dates,
/// code mono). Footer 3 boutons ghost si [upcoming] = true.
class TripCard extends StatelessWidget {
  final ListingPreview listing;
  final String status;
  final String dates;
  final String code;
  final bool upcoming;
  final VoidCallback? onTap;
  final VoidCallback? onContactHost;
  final VoidCallback? onItinerary;
  final VoidCallback? onReceipt;

  const TripCard({
    super.key,
    required this.listing,
    required this.status,
    required this.dates,
    required this.code,
    this.upcoming = false,
    this.onTap,
    this.onContactHost,
    this.onItinerary,
    this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: ImgPh(tone: listing.tone, radius: 0),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BadgeStatus(
                              text: status,
                              tone: upcoming
                                  ? BadgeTone.success
                                  : BadgeTone.neutral,
                            ),
                            const SizedBox(height: 6),
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
                            const SizedBox(height: 4),
                            Text(
                              dates,
                              style: AppTextStyles.small.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              code,
                              style: AppTextStyles.mono(
                                AppTextStyles.small.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (upcoming)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.line, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlainButton(
                          text: 'Hôte',
                          onPressed: onContactHost,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.chat_bubble_outline,
                          textColor: AppColors.text,
                        ),
                      ),
                      Expanded(
                        child: PlainButton(
                          text: 'Itinéraire',
                          onPressed: onItinerary,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.map_outlined,
                          textColor: AppColors.text,
                        ),
                      ),
                      Expanded(
                        child: PlainButton(
                          text: 'Reçu',
                          onPressed: onReceipt,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.description_outlined,
                          textColor: AppColors.text,
                        ),
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
