import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_calendar_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_hero.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_stats_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_infos_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_reductions_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_rules_tab.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Édition d'une annonce — `ProprioListingEditScreen`.
///
/// Consomme directement le modèle métier [Appartement]. Reproduit
/// `ProprietaireListingEdit` du prototype : Hero photo 16:10 + stats card
/// compacte + 4 onglets via `DefaultTabController` (Infos / Calendrier /
/// Tarifs / Règles) avec indicator underline accent or.
class ProprioListingEditScreen extends StatelessWidget {
  final Appartement appartement;
  final int initialTab;
  final double occupancyRate;

  const ProprioListingEditScreen({
    super.key,
    required this.appartement,
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

  /// Cherche la version fraîche de l'Appartement dans le cache du BLoC.
  /// Renvoie null si non trouvé (cas où le screen est ouvert depuis un push
  /// qui n'a pas préalablement chargé les appartements proprio).
  Appartement? _findFresh(List<Appartement> apparts) {
    final id = appartement.id;
    if (id == null) return null;
    for (final a in apparts) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: DynamicAppBar(
          title: appartement.titleSafe,
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
              SliverToBoxAdapter(
                  child: ListingEditHero(appartement: appartement)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: ListingEditStatsCard(
                    appartement: appartement,
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
            body: BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, state) {
                final source = _findFresh(state.appartements);
                return TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingInfosTab(
                        appartement: appartement,
                        source: source,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingCalendarTab(
                        appartementId: appartement.id,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingReductionsTab(
                        appartement: appartement,
                        source: source,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingRulesTab(source: source),
                    ),
                  ],
                );
              },
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
          Tab(text: 'Réductions'),
          Tab(text: 'Règles'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
