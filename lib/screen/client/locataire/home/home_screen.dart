import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/home/search_screen.dart';
import 'package:asfar/screen/client/locataire/home/widget/listing_filter_chips.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_home_header.dart';
import 'package:asfar/screen/client/locataire/home/widget/locataire_search_bar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';
import 'package:asfar/widget/card/featured_listing_card.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/map/map_teaser.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Écran d'accueil Locataire — Explorer.
///
/// V8.5 : branché sur `AppartementBloc` (au lieu de `SampleListings.all`).
/// Utilise `state.appartements` (exposé par toutes les variantes Loaded du
/// BLoC, y compris pendant Loading/Error pour le pattern cache-first).
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

  @override
  void initState() {
    super.initState();
    // Trigger un load au mount si pas déjà en cache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AppartementBloc>();
      if (bloc.state.appartements.isEmpty) {
        bloc.add(LoadAppartements());
      }
    });
  }

  void _onListingTap(ListingPreview listing) {
    pushScreen(context, LocataireDetailScreen(listing: listing));
  }

  void _onSearchTap() {
    pushScreen(context, const LocataireSearchScreen());
  }

  void _onRetry() {
    context.read<AppartementBloc>().add(RefreshAppartements());
  }

  void _onToggleFavorite(ListingPreview listing) {
    final apartId = int.tryParse(listing.id);
    if (apartId == null) return;
    context.read<FavoriteBloc>().add(ToggleFavorite(apartId));
  }

  List<int> _favoriteIdsFromState(FavoriteState state) {
    if (state is FavoriteLoaded) return state.favoriteIds;
    if (state is FavoriteOptimisticUpdate) return state.favoriteIds;
    if (state is FavoriteActionSuccess) return state.favoriteIds;
    if (state is FavoriteError) return state.favoriteIds ?? const [];
    return const [];
  }

  bool _isLiked(List<int> ids, ListingPreview listing) {
    final apartId = int.tryParse(listing.id);
    return apartId != null && ids.contains(apartId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, state) {
            final listings =
                AppartementToListingMapper.mapMany(state.appartements);
            final isInitialLoading =
                state is AppartementLoading && listings.isEmpty;
            final isErrorWithoutCache =
                state is AppartementError && listings.isEmpty;

            if (isInitialLoading) return _buildLoading();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            return _buildContent(listings);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 100, 18, 100),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 220),
    );
  }

  Widget _buildContent(List<ListingPreview> listings) {
    return CustomScrollView(
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
        if (listings.isEmpty)
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
            child: SizedBox(
              height: 348,
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, favState) {
                  final favIds = _favoriteIdsFromState(favState);
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: listings.take(3).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final l = listings[i];
                      return FeaturedListingCard(
                        listing: l,
                        liked: _isLiked(favIds, l),
                        onTap: () => _onListingTap(l),
                        onLikeTap: () => _onToggleFavorite(l),
                      );
                    },
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
                totalListings: listings.length,
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
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, favState) {
                  final favIds = _favoriteIdsFromState(favState);
                  return Column(
                    children: [
                      for (var i = 0; i < listings.length; i++) ...[
                        AppartementPreviewCard(
                          listing: listings[i],
                          liked: _isLiked(favIds, listings[i]),
                          onTap: () => _onListingTap(listings[i]),
                          onLikeTap: () => _onToggleFavorite(listings[i]),
                        ),
                        if (i != listings.length - 1)
                          const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ],
    );
  }
}
