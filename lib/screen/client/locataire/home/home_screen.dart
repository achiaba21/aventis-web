import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/home/search_screen.dart';
import 'package:asfar/screen/client/locataire/home/widget/featured_listings_carousel.dart';
import 'package:asfar/screen/client/locataire/map/locataire_map_screen.dart';
import 'package:asfar/screen/client/locataire/home/widget/listing_filter_chips.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_home_header.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_home_loading_view.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_search_bar.dart';
import 'package:asfar/screen/client/locataire/home/widget/recommended_listings_list.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/loader_circular.dart';
import 'package:asfar/widget/map/map_teaser.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Écran d'accueil Locataire — Explorer.
class LocataireHomeScreen extends StatefulWidget {
  final String firstName;

  const LocataireHomeScreen({super.key, this.firstName = 'Aïcha'});

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
  static const List<List<double>> _pinPositions = [
    [0.30, 0.35],
    [0.60, 0.55],
    [0.75, 0.30],
    [0.45, 0.70],
  ];

  /// Distance restante (px) sous laquelle la page suivante est demandée
  /// (PERF-02 — déclenche avant que l'utilisateur n'atteigne le bas).
  static const double _loadMoreThresholdPx = 500;

  String _filter = 'Tout';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AppartementBloc>();
      if (bloc.state.appartements.isEmpty) {
        bloc.add(LoadAppartements());
      }
    });
  }

  void _onListingTap(Appartement appartement) {
    pushScreen(context, LocataireDetailScreen(appartement: appartement));
  }

  void _onSearchTap() {
    pushScreen(context, const LocataireSearchScreen());
  }

  void _onRetry() {
    context.read<AppartementBloc>().add(RefreshAppartements());
  }

  void _onSeeMap() {
    pushScreen(context, const LocataireMapScreen());
  }

  /// Génère 1 à 4 pins distribués sur le teaser à partir des appartements réels.
  List<MapTeaserPin> _pinsForAppartements(List<Appartement> appartements) {
    if (appartements.isEmpty) return const [];
    final count =
        appartements.length < _pinPositions.length
            ? appartements.length
            : _pinPositions.length;
    return [
      for (var i = 0; i < count; i++)
        MapTeaserPin(
          x: _pinPositions[i][0],
          y: _pinPositions[i][1],
          label: _compactPriceLabel(appartements[i].priceAmount),
          active: i == 0,
        ),
    ];
  }

  String _compactPriceLabel(int price) {
    if (price >= 1000000) {
      final m = price / 1000000;
      return '${m.toStringAsFixed(m % 1 == 0 ? 0 : 1)}M';
    }
    if (price >= 1000) {
      return '${(price / 1000).round()}k';
    }
    return '$price';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, state) {
            final appartements = state.appartements;
            final isInitialLoading =
                state is AppartementLoading && appartements.isEmpty;
            final isErrorWithoutCache =
                state is AppartementError && appartements.isEmpty;

            if (isInitialLoading) return const LocataireHomeLoadingView();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            // PERF-02 : pagination du feed au scroll. Les gardes du bloc
            // (isLoadingMore / hasReachedEnd) neutralisent les déclenchements
            // répétés ; sans backend paginé le comportement reste identique.
            final isLoadingMore =
                state is AppartementLoaded && state.isLoadingMore;
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < _loadMoreThresholdPx) {
                  context.read<AppartementBloc>().add(LoadMoreAppartements());
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                      child: Column(
                        children: [
                          LocataireHomeHeader(
                            firstName: widget.firstName,
                            onBellTap:
                                () => pushScreen(
                                  context,
                                  const NotificationsScreen(),
                                ),
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
                  if (appartements.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState.hero(
                        icon: Icons.home_work_outlined,
                        title: 'Aucun logement disponible',
                        body:
                            'Aucun appartement ne correspond pour le moment. Revenez plus tard.',
                        ctaLabel: 'Actualiser',
                        onCtaTap: _onRetry,
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'À la une',
                        actionLabel: 'Voir tout',
                        onActionTap: () {},
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FeaturedListingsCarousel(
                        appartements: appartements,
                        onTap: _onListingTap,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Près de vous',
                        actionLabel: 'Voir carte',
                        onActionTap: _onSeeMap,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: MapTeaser(
                          pins: _pinsForAppartements(appartements),
                          totalListings: appartements.length,
                          onSeeMap: _onSeeMap,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 4)),
                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Recommandés pour vous'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      sliver: SliverToBoxAdapter(
                        child: RecommendedListingsList(
                          appartements: appartements,
                          onTap: _onListingTap,
                        ),
                      ),
                    ),
                    // Loader de page suivante (UI validée : LoaderCircular)
                    if (isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: LoaderCircular()),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
