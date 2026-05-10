import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_calendar_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_hero.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_stats_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_infos_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_pricing_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_rules_tab.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Édition d'une annonce — `ProprioListingEditScreen`.
///
/// Reproduit `ProprietaireListingEdit` du prototype : Hero photo 16:10 +
/// stats card compacte + 4 onglets via `DefaultTabController`
/// (Infos / Calendrier / Tarifs / Règles) avec indicator underline accent or.
class ProprioListingEditScreen extends StatelessWidget {
  final ListingPreview listing;
  final int initialTab;
  final double occupancyRate;

  const ProprioListingEditScreen({
    super.key,
    required this.listing,
    this.initialTab = 0,
    this.occupancyRate = 0.84,
  });

  void _stub(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: DynamicAppBar(
          title: listing.title,
          eyebrow: 'ANNONCE ACTIVE',
          leading: IconBoutton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => back(context),
          ),
          trailing: IconBoutton(
            icon: Icons.more_vert,
            onPressed: () => _stub(context, "Plus d'options bientôt"),
          ),
        ),
        body: SafeArea(
          top: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(child: ListingEditHero(listing: listing)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: ListingEditStatsCard(
                    listing: listing,
                    occupancyRate: occupancyRate,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(),
              ),
            ],
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                  child: ListingInfosTab(listing: listing),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                  child: const ListingCalendarTab(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                  child: ListingPricingTab(listing: listing),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                  child: const ListingRulesTab(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.text3,
        labelStyle: AppTextStyles.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        dividerColor: AppColors.line,
        tabAlignment: TabAlignment.fill,
        tabs: const [
          Tab(text: 'Infos'),
          Tab(text: 'Calendrier'),
          Tab(text: 'Tarifs'),
          Tab(text: 'Règles'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
