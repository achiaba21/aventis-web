import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/screen/client/proprio/appartements/listing_edit_screen.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listings_filter_chips.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/new_listing_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Liste des annonces du propriétaire — onglet Annonces du `ProprioShell`.
///
/// V8.5 : branché sur `AppartementBloc` via l'event `LoadProprietaireAppartements`
/// qui charge uniquement les annonces du propriétaire connecté. Affiche les
/// vraies annonces depuis le backend.
///
/// Note : `occupancyRate` et `monthlyRevenue` restent à 0/heuristique simple
/// jusqu'à Lot 8 qui apportera `KpiAggregator` (calcul depuis Reservation
/// history + Charge). Pour l'instant, les KPIs OCCUP/REV. MOIS afficheront
/// `0%` / `0 FCFA` ou des valeurs neutres.
class ProprioListingsScreen extends StatefulWidget {
  const ProprioListingsScreen({super.key});

  @override
  State<ProprioListingsScreen> createState() => _ProprioListingsScreenState();
}

class _ProprioListingsScreenState extends State<ProprioListingsScreen> {
  String _filter = 'Tout';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AppartementBloc>();
      // Charge les annonces du proprio si pas déjà en cache
      if (bloc.state.appartements.isEmpty) {
        bloc.add(LoadProprietaireAppartements());
      }
    });
  }

  void _stub(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRetry() {
    context.read<AppartementBloc>().add(RefreshProprietaireAppartements());
  }

  List<String> _buildFilters(int total) {
    return [
      'Tout ($total)',
      'Actifs ($total)',
      'En pause (0)',
      'Brouillon (0)',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes annonces',
        leading: Navigator.canPop(context)
            ? IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              )
            : null,
        trailing: IconBoutton(
          icon: Icons.add,
          onPressed: () =>
              _stub('Création d\'annonce disponible prochainement (F2)'),
        ),
      ),
      body: SafeArea(
        top: false,
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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 320),
    );
  }

  Widget _buildContent(List<ListingPreview> listings) {
    return Column(
      children: [
        const SizedBox(height: 6),
        ListingsFilterChips(
          filters: _buildFilters(listings.length),
          selected: _filter.startsWith('Tout') ? 'Tout (${listings.length})' : _filter,
          onSelect: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: listings.isEmpty
              ? EmptyState.hero(
                  icon: Icons.home_work_outlined,
                  title: 'Aucune annonce',
                  body:
                      'Vos annonces publiées apparaîtront ici.\nCommencez par publier votre 1ère annonce.',
                  ctaLabel: 'Nouvelle annonce',
                  onCtaTap: () => _stub(
                      'Création d\'annonce disponible prochainement (F2)'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  child: Column(
                    children: [
                      for (var i = 0; i < listings.length; i++) ...[
                        ListingFullCard(
                          listing: listings[i],
                          // KPIs occupancyRate + monthlyRevenue à 0 jusqu'à
                          // Lot 8 (KpiAggregator depuis Reservation history)
                          occupancyRate: 0,
                          monthlyRevenue: 0,
                          onTap: () => pushScreen(
                            context,
                            ProprioListingEditScreen(listing: listings[i]),
                          ),
                          onMoreTap: () => _stub("Plus d'options bientôt"),
                          onCalendarTap: () => pushScreen(
                            context,
                            ProprioListingEditScreen(
                              listing: listings[i],
                              initialTab: 1,
                            ),
                          ),
                          onEditTap: () => pushScreen(
                            context,
                            ProprioListingEditScreen(
                              listing: listings[i],
                              initialTab: 0,
                            ),
                          ),
                          onStatsTap: () => _stub(
                              'Statistiques détaillées disponibles prochainement'),
                        ),
                        const SizedBox(height: 14),
                      ],
                      NewListingCard(
                        onTap: () => _stub(
                            'Création d\'annonce disponible prochainement (F2)'),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
