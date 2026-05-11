import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_body.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_footer.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_hero.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card complète d'annonce — `ProprioListingsScreen`.
///
/// Consomme directement [Appartement]. Reproduit le proto
/// `proprietaire.jsx::ProprietaireListings` (lignes 377-430). Composée de
/// 3 sous-widgets : Hero (image + badges + more), Body (titre + prix + KPIs),
/// Footer (3 boutons Calendrier / Modifier / Stats).
class ListingFullCard extends StatelessWidget {
  final Appartement appartement;
  final double occupancyRate;
  final int monthlyRevenue;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onStatsTap;

  const ListingFullCard({
    super.key,
    required this.appartement,
    required this.occupancyRate,
    required this.monthlyRevenue,
    this.onTap,
    this.onMoreTap,
    this.onCalendarTap,
    this.onEditTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListingFullCardHero(
                appartement: appartement,
                onMoreTap: onMoreTap,
              ),
              ListingFullCardBody(
                appartement: appartement,
                occupancyRate: occupancyRate,
                monthlyRevenue: monthlyRevenue,
              ),
              ListingFullCardFooter(
                onCalendarTap: onCalendarTap,
                onEditTap: onEditTap,
                onStatsTap: onStatsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
