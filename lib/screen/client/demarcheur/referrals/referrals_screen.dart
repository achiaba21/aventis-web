import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/listings/demarcheur_listings_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/new_demande_flying_button.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_filter_chips.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referrals_list_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referrals_loading_view.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Mes demandes » du Démarcheur — onglet Referrals.
///
/// Consomme directement la liste `Reservation` du `DemarcheurBloc`.
/// La logique de présentation (status, client, commission, nights) est
/// exposée par l'extension `ReferralDisplay` sur `Reservation`.
class DemarcheurReferralsScreen extends StatefulWidget {
  const DemarcheurReferralsScreen({super.key});

  @override
  State<DemarcheurReferralsScreen> createState() =>
      _DemarcheurReferralsScreenState();
}

class _DemarcheurReferralsScreenState extends State<DemarcheurReferralsScreen> {
  static const _filters = [
    'Toutes',
    'En attente',
    'Acceptées',
    'Terminées',
    'Refusées',
  ];

  String _filter = 'Toutes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DemarcheurBloc>().add(LoadDemarcheurReservations());
    });
  }

  ReferralStatus? _statusForFilter(String f) {
    switch (f) {
      case 'En attente':
        return ReferralStatus.pending;
      case 'Acceptées':
        return ReferralStatus.accepted;
      case 'Terminées':
        return ReferralStatus.completed;
      case 'Refusées':
        return ReferralStatus.refused;
      default:
        return null;
    }
  }

  void _onOpenNew() =>
      pushScreen(context, const DemarcheurListingsScreen());

  void _onOpenDetail(Reservation reservation) {
    pushScreen(
      context,
      ReferralDetailScreen(reservation: reservation),
    );
  }

  String _emptyTitleFor(String filter) {
    if (filter == 'Toutes') return 'Aucune demande envoyée';
    return 'Aucune demande $filter'.toLowerCase();
  }

  String _emptyBodyFor(String filter) {
    if (filter == 'Toutes') {
      return 'Référencez votre premier client pour commencer à gagner des commissions.';
    }
    return 'Aucune demande dans cette catégorie pour le moment.';
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes demandes',
        leading: canPop
            ? IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<DemarcheurBloc, DemarcheurState>(
          builder: (context, state) {
            if (state is DemarcheurLoading) return const ReferralsLoadingView();
            if (state is DemarcheurError) {
              return EmptyState.error(
                message: state.message,
                onRetry: () => context
                    .read<DemarcheurBloc>()
                    .add(LoadDemarcheurReservations()),
              );
            }
            final reservations = state is DemarcheurDataLoaded
                ? state.reservations
                : <Reservation>[];
            final wanted = _statusForFilter(_filter);
            final visible = wanted == null
                ? reservations
                : reservations
                    .where((r) => r.referralStatus == wanted)
                    .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                ReferralFilterChips(
                  filters: _filters,
                  selected: _filter,
                  onSelect: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: visible.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                // CTA retiré : c'est le bouton volant unique
                                // (ci-dessous) qui sert d'appel à l'action.
                                child: EmptyState.hero(
                                  icon: Icons.people_outline,
                                  title: _emptyTitleFor(_filter),
                                  body: _emptyBodyFor(_filter),
                                ),
                              )
                            : Padding(
                                // Réserve la bande basse occupée par le bouton :
                                // le viewport de la liste s'arrête au-dessus,
                                // donc aucun item ne défile derrière lui.
                                padding: const EdgeInsets.only(
                                  bottom:
                                      NewDemandeFlyingButton.dockedStripHeight,
                                ),
                                child: ReferralsListCard(
                                  reservations: visible,
                                  onTap: _onOpenDetail,
                                ),
                              ),
                      ),
                      // Bouton unique : centré (allure bloc) quand la liste est
                      // vide, calé dans la bande basse (allure FAB) sinon, avec
                      // vol/morph « hero » au changement de filtre.
                      Positioned.fill(
                        child: NewDemandeFlyingButton(
                          centered: visible.isEmpty,
                          onTap: _onOpenNew,
                        ),
                      ),
                    ],
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
