import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/screen/client/proprio/appartements/listing_edit_screen.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listings_filter_chips.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/new_listing_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/proprio_listings_loading_view.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/proprio_new_listing_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/listing_status_filter.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Liste des annonces du propriétaire — onglet Annonces du `ProprioShell`.
class ProprioListingsScreen extends StatefulWidget {
  const ProprioListingsScreen({super.key});

  @override
  State<ProprioListingsScreen> createState() => _ProprioListingsScreenState();
}

class _ProprioListingsScreenState extends State<ProprioListingsScreen> {
  ListingFilter _filter = ListingFilter.tout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AppartementBloc>();
      // Cache-first pour un affichage instantané si la liste est vide, sinon
      // (liste déjà préchargée au login, potentiellement périmée) on force un
      // rafraîchissement API : garantit des statuts à jour et réécrit le cache.
      if (bloc.state.appartements.isEmpty) {
        bloc.add(LoadProprietaireAppartements());
      } else {
        bloc.add(RefreshProprietaireAppartements());
      }
    });
  }

  void _onRetry() {
    context.read<AppartementBloc>().add(RefreshProprietaireAppartements());
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
          onPressed: () => pushScreen(
            context,
            const ProprioNewListingScreen(),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, state) {
            final appartements = state.appartements;
            final isInitialLoading =
                state is AppartementLoading && appartements.isEmpty;
            final isErrorWithoutCache =
                state is AppartementError && appartements.isEmpty;

            if (isInitialLoading) return const ProprioListingsLoadingView();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            final filtered = ListingStatusFilter.apply(appartements, _filter);
            return Column(
              children: [
                const SizedBox(height: 6),
                ListingsFilterChips(
                  filters: [
                    for (final f in ListingFilter.values)
                      ListingStatusFilter.label(appartements, f),
                  ],
                  selected: ListingStatusFilter.label(appartements, _filter),
                  onSelect: (label) => setState(() => _filter =
                      ListingStatusFilter.fromLabel(appartements, label)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: appartements.isEmpty
                      ? EmptyState.hero(
                          icon: Icons.home_work_outlined,
                          title: 'Aucune annonce',
                          body:
                              'Vos annonces publiées apparaîtront ici.\nCommencez par publier votre 1ère annonce.',
                          ctaLabel: 'Nouvelle annonce',
                          onCtaTap: () => pushScreen(
                            context,
                            const ProprioNewListingScreen(),
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: EmptyState.inline(
                                icon: Icons.filter_list_off,
                                title: 'Aucune annonce',
                                body:
                                    'Aucune annonce ne correspond à ce filtre.',
                              ),
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 0, 18, 100),
                              child: Column(
                                children: [
                                  for (var i = 0; i < filtered.length; i++) ...[
                                    ListingFullCard(
                                      appartement: filtered[i],
                                      occupancyRate: 0,
                                      monthlyRevenue: 0,
                                      onTap: () => pushScreen(
                                        context,
                                        ProprioListingEditScreen(
                                            appartement: filtered[i]),
                                      ),
                                      onCalendarTap: () => pushScreen(
                                        context,
                                        ProprioListingEditScreen(
                                          appartement: filtered[i],
                                          initialTab: 1,
                                        ),
                                      ),
                                      onEditTap: () => pushScreen(
                                        context,
                                        ProprioListingEditScreen(
                                          appartement: filtered[i],
                                          initialTab: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  NewListingCard(
                                    onTap: () => pushScreen(
                                      context,
                                      const ProprioNewListingScreen(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
