import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/card/saved_listing_card.dart';

/// Écran Favoris du Locataire.
///
/// Reproduit `SavedScreen` du proto : grid 2 colonnes de cards 1:1 avec
/// heart actif en top-right.
class LocataireFavoriteScreen extends StatelessWidget {
  const LocataireFavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = SampleListings.all;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Favoris'),
      body: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: listings.length,
          itemBuilder: (_, i) => SavedListingCard(
            listing: listings[i],
            onTap: () => pushScreen(
              context,
              LocataireDetailScreen(listing: listings[i]),
            ),
          ),
        ),
      ),
    );
  }
}
