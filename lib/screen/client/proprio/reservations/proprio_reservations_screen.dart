import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/proprio_reservations_filter_cubit/proprio_reservations_filter_cubit.dart';
import 'package:asfar/bloc/proprio_reservations_filter_cubit/proprio_reservations_filter_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/proprio_reservations_list.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/reservations_appartement_selector.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/reservations_segment_chips_row.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/reservations_loading_view.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_detail_screen.dart';
import 'package:asfar/util/calc/proprio_reservations_filter.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/util/calc/reservation_segment.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Mes réservations » du propriétaire — vue de toutes les demandes.
///
/// Branché sur `ReservationBloc` via `LoadProprietaireReservations`. Le filtre
/// est piloté par un `ProprioReservationsFilterCubit` local :
/// - segments « par intention » : À traiter / À venir / Historique (compteurs) ;
/// - filtre par bien combinable (sélecteur « Tous les biens ▾ ») ;
/// - tri automatique par urgence selon le segment.
///
/// La logique de filtrage/tri/comptage vit dans `ProprioReservationsFilter`.
class ProprioReservationsScreen extends StatefulWidget {
  const ProprioReservationsScreen({super.key});

  @override
  State<ProprioReservationsScreen> createState() =>
      _ProprioReservationsScreenState();
}

class _ProprioReservationsScreenState
    extends State<ProprioReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReservationBloc>().add(LoadProprietaireReservations());
    });
  }

  void _onRetry() {
    context
        .read<ReservationBloc>()
        .add(RefreshReservations(isProprietaire: true));
  }

  void _onRowTap(Reservation r) {
    pushScreen(
      context,
      ReservationDetailScreen(
        reservation: r,
        viewerRole: ReservationViewerRole.proprietaire,
      ),
    );
  }

  String _emptyTitle(ReservationSegment segment) {
    switch (segment) {
      case ReservationSegment.aTraiter:
        return 'Aucune demande à traiter';
      case ReservationSegment.aVenir:
        return 'Aucune réservation à venir';
      case ReservationSegment.historique:
        return 'Aucun historique';
    }
  }

  String _emptyBody(ReservationSegment segment) {
    switch (segment) {
      case ReservationSegment.aTraiter:
        return 'Les nouvelles demandes de réservation à confirmer apparaîtront ici.';
      case ReservationSegment.aVenir:
        return 'Vos séjours confirmés et à venir s\'afficheront ici.';
      case ReservationSegment.historique:
        return 'Les réservations terminées ou annulées seront archivées ici.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProprioReservationsFilterCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: DynamicAppBar(
          title: 'Mes réservations',
          leading: IconBoutton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => back(context),
          ),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<ReservationBloc, ReservationState>(
            builder: (context, resState) {
              final all = resState.reservations;
              final isInitialLoading =
                  resState is ReservationLoading && all.isEmpty;
              final isErrorWithoutCache =
                  resState is ReservationError && all.isEmpty;

              if (isInitialLoading) return const ReservationsLoadingView();
              if (isErrorWithoutCache) {
                return EmptyState.error(
                  message: resState.message,
                  onRetry: _onRetry,
                );
              }

              return BlocBuilder<ProprioReservationsFilterCubit,
                  ProprioReservationsFilterState>(
                builder: (context, filter) {
                  final now = DateTime.now();
                  final cubit =
                      context.read<ProprioReservationsFilterCubit>();
                  final appartements =
                      ProprioReservationsFilter.distinctAppartements(all);
                  final counts = ProprioReservationsFilter.counts(
                    all: all,
                    now: now,
                    appartementId: filter.appartementId,
                  );
                  final visible = ProprioReservationsFilter.apply(
                    all: all,
                    segment: filter.segment,
                    now: now,
                    appartementId: filter.appartementId,
                  );

                  return Column(
                    children: [
                      const SizedBox(height: 6),
                      ReservationsSegmentChipsRow(
                        selected: filter.segment,
                        counts: counts,
                        onSelect: cubit.selectSegment,
                      ),
                      // Sélecteur de bien : utile seulement si le proprio a des
                      // réservations sur plusieurs biens distincts.
                      if (appartements.length > 1) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              ReservationsAppartementSelector(
                                appartements: appartements,
                                selectedId: filter.appartementId,
                                onSelect: cubit.selectAppartement,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Expanded(
                        child: visible.isEmpty
                            ? EmptyState.hero(
                                icon: Icons.inbox_outlined,
                                title: _emptyTitle(filter.segment),
                                body: _emptyBody(filter.segment),
                              )
                            : ProprioReservationsList(
                                reservations: visible,
                                onRowTap: _onRowTap,
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
