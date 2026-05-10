import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/proprio_reservation_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran « Mes réservations » du propriétaire — page dédiée pour voir TOUTES
/// les demandes de réservation reçues (pas seulement celles en attente).
///
/// Hors-proto V8.5 mais ajouté car le proto initial ne propose pas d'écran
/// dédié — le seul accès aux réservations était la section limitée du
/// Dashboard (`Demandes en attente`) ou le futur `ProprietaireCalendar` (V9
/// proto étendu, vue mensuelle).
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

            if (isInitialLoading) return _buildLoading();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            return _buildContent(all);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 60, 18, 100),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 70),
    );
  }

  Widget _buildContent(List<Reservation> all) {
    final visible = all.where(_matches).toList();
    return Column(
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              return AsfarChip(
                label: f,
                active: f == _filter,
                onTap: () => setState(() => _filter = f),
              );
            },
          ),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgElev1,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.line, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          ProprioReservationRow(
                            reservation: visible[i],
                            isLast: i == visible.length - 1,
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Détail réservation disponible prochainement'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
