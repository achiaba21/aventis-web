import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_more_button.dart';
import 'package:asfar/util/calc/appartement_status_display.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Hero image 16:9 d'une `ListingFullCard` avec badges Actif + Certifié
/// et bouton « more » blur top-right.
class ListingFullCardHero extends StatelessWidget {
  final Appartement appartement;
  final VoidCallback? onMoreTap;

  const ListingFullCardHero({
    super.key,
    required this.appartement,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(
            child: DomainImage(
              path: appartement.firstPhotoPath,
              placeholder: ImgPh(tone: appartement.tone, radius: 0),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BadgeStatus(
                  text: AppartementStatusDisplay.badgeLabel(
                      appartement.status),
                  tone: AppartementStatusDisplay.badgeTone(appartement.status),
                ),
                if (appartement.isSuperhost) ...[
                  const SizedBox(width: 6),
                  const BadgeStatus(
                      text: '★ Certifié', tone: BadgeTone.accent),
                ],
              ],
            ),
          ),
          if (onMoreTap != null)
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
