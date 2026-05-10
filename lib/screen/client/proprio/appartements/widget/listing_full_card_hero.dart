import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_more_button.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Hero image 16:9 d'une `ListingFullCard` avec badges Actif + Certifié
/// et bouton « more » blur top-right.
class ListingFullCardHero extends StatelessWidget {
  final ListingPreview listing;
  final VoidCallback? onMoreTap;

  const ListingFullCardHero({
    super.key,
    required this.listing,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(child: ImgPh(tone: listing.tone, radius: 0)),
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BadgeStatus(text: '● Actif', tone: BadgeTone.success),
                if (listing.superhost) ...[
                  const SizedBox(width: 6),
                  const BadgeStatus(
                      text: '★ Certifié', tone: BadgeTone.accent),
                ],
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: ListingFullCardMoreButton(onTap: onMoreTap),
          ),
        ],
      ),
    );
  }
}
