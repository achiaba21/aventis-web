import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';
import 'package:asfar/screen/client/locataire/home/search_screen.dart';
import 'package:asfar/screen/client/locataire/home/widget/listing_filter_chips.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_home_header.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_search_bar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';
import 'package:asfar/widget/card/featured_listing_card.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/map/map_teaser.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Écran d'accueil Locataire — Explorer.
///
/// Reproduit `LocataireHome` du proto :
/// 1. Header (greeting + bell + avatar)
/// 2. Search bar tappable
/// 3. Chips filtres horizontales
/// 4. Section "À la une" + carrousel `FeaturedListingCard`
/// 5. Section "Près de vous" + `MapTeaser` (4 pins prix)
/// 6. Section "Recommandés pour vous" + liste verticale `AppartementPreviewCard`
class LocataireHomeScreen extends StatefulWidget {
  final String firstName;

  const LocataireHomeScreen({
    super.key,
    this.firstName = 'Aïcha',
  });

  @override
  State<LocataireHomeScreen> createState() => _LocataireHomeScreenState();
}

class _LocataireHomeScreenState extends State<LocataireHomeScreen> {
  static const List<String> _filters = [
    'Tout',
    'Studio',
    '1 chambre',
    '2+ chambres',
    'Avec piscine',
    'Court séjour',
  ];
  static const List<MapTeaserPin> _mapPins = [
    MapTeaserPin(x: 0.30, y: 0.35, label: '45k'),
    MapTeaserPin(x: 0.60, y: 0.55, label: '32k', active: true),
    MapTeaserPin(x: 0.75, y: 0.30, label: '68k'),
    MapTeaserPin(x: 0.45, y: 0.70, label: '55k'),
  ];

  String _filter = 'Tout';

  void _onListingTap(ListingPreview listing) {
    pushScreen(context, LocataireDetailScreen(listing: listing));
  }

  void _onSearchTap() {
    pushScreen(context, const LocataireSearchScreen());
  }

  @override
  Widget build(BuildContext context) {
    final listings = SampleListings.all;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  children: [
                    LocataireHomeHeader(
                      firstName: widget.firstName,
                      onBellTap: () {},
                      onAvatarTap: () {},
                    ),
                    const SizedBox(height: 14),
                    LocataireSearchBar(
                      summary: 'Abidjan · 12-15 nov · 2 voyageurs',
                      onTap: _onSearchTap,
                      onFiltersTap: _onSearchTap,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ListingFilterChips(
                filters: _filters,
                selected: _filter,
                onSelect: (f) => setState(() => _filter = f),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'À la une',
                actionLabel: 'Voir tout',
                onActionTap: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 322,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: listings.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final l = listings[i];
                    return FeaturedListingCard(
                      listing: l,
                      onTap: () => _onListingTap(l),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Près de vous',
                actionLabel: 'Voir carte',
                onActionTap: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: MapTeaser(
                  pins: _mapPins,
                  totalListings: 124,
                  onSeeMap: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Recommandés pour vous'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList.separated(
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final l = listings[i];
                  return AppartementPreviewCard(
                    listing: l,
                    onTap: () => _onListingTap(l),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
