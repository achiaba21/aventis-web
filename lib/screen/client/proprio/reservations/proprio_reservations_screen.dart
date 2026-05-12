import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/proprio_reservations_list.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_detail_screen.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/reservations_filter_chips_row.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/reservations_loading_view.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Mes réservations » du propriétaire — vue de toutes les demandes.
///
/// Branché sur `ReservationBloc` via `LoadProprietaireReservations`. Filtres
/// chips par statut : Toutes / En attente / Confirmées / Terminées / Refusées.
class ProprioReservationsScreen extends StatefulWidget {
  const ProprioReservationsScreen({super.key});

  @override
  State<ProprioReservationsScreen> createState() =>
      _ProprioReservationsScreenState();
}

class _ProprioReservationsScreenState
    extends State<ProprioReservationsScreen> {
  static const _filters = [
    'Toutes',
    'En attente',
    'Confirmées',
    'Terminées',
    'Refusées',
  ];

  String _filter = 'Toutes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReservationBloc>().add(LoadProprietaireReservations());
    });
  }

  void _onRetry() {
    context.read<ReservationBloc>().add(RefreshReservations());
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

  bool _matches(Reservation r) {
    switch (_filter) {
      case 'En attente':
        return r.statut == ReservationStatus.enAttente;
      case 'Confirmées':
        return r.statut == ReservationStatus.confirmee ||
            r.statut == ReservationStatus.payee;
      case 'Terminées':
        return r.statut == ReservationStatus.terminee ||
            r.statut == ReservationStatus.finalisee;
      case 'Refusées':
        return r.statut == ReservationStatus.refusee ||
            r.statut == ReservationStatus.annulee;
      case 'Toutes':
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          builder: (context, state) {
            final all = state.reservations;
            final isInitialLoading =
                state is ReservationLoading && all.isEmpty;
            final isErrorWithoutCache =
                state is ReservationError && all.isEmpty;

            if (isInitialLoading) return const ReservationsLoadingView();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            final visible = all.where(_matches).toList();
            return Column(
              children: [
                const SizedBox(height: 6),
                ReservationsFilterChipsRow(
                  filters: _filters,
                  selected: _filter,
                  onSelect: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: visible.isEmpty
                      ? EmptyState.hero(
                          icon: Icons.inbox_outlined,
                          title: _filter == 'Toutes'
                              ? 'Aucune réservation'
                              : 'Aucune dans cette catégorie',
                          body: _filter == 'Toutes'
                              ? 'Les demandes de réservation reçues sur vos annonces apparaîtront ici.'
                              : 'Essayez un autre filtre.',
                        )
                      : ProprioReservationsList(
                          reservations: visible,
                          onRowTap: _onRowTap,
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
