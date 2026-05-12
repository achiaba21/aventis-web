import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/screen/client/locataire/trips/widget/trip_card.dart';
import 'package:asfar/screen/client/locataire/trips/widget/trips_filter_chips.dart';
import 'package:asfar/screen/client/locataire/trips/widget/trips_loading_view.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran "Mes voyages" du Locataire — branché sur `ReservationBloc`.
///
/// Consomme directement la liste `Reservation` du BLoC. La logique
/// « à venir / passé » est exposée par l'extension `TripDisplay` sur
/// `Reservation` (voir `widget/trip_card.dart`).
class LocataireTripsScreen extends StatefulWidget {
  const LocataireTripsScreen({super.key});

  @override
  State<LocataireTripsScreen> createState() => _LocataireTripsScreenState();
}

class _LocataireTripsScreenState extends State<LocataireTripsScreen> {
  bool _upcoming = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<ReservationBloc>();
      if (bloc.state.reservations.isEmpty) {
        bloc.add(LoadUserReservations());
      }
    });
  }

  void _onRetry() {
    context.read<ReservationBloc>().add(RefreshReservations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Mes voyages'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, state) {
            final reservations = state.reservations;
            final isInitialLoading =
                state is ReservationLoading && reservations.isEmpty;
            final isErrorWithoutCache =
                state is ReservationError && reservations.isEmpty;

            if (isInitialLoading) return const TripsLoadingView();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            final upcomingCount =
                reservations.where((r) => r.isUpcomingTrip).length;
            final pastCount = reservations.length - upcomingCount;
            final filtered = reservations
                .where((r) => r.isUpcomingTrip == _upcoming)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TripsFilterChips(
                    upcomingCount: upcomingCount,
                    pastCount: pastCount,
                    upcoming: _upcoming,
                    onUpcomingChanged: (v) => setState(() => _upcoming = v),
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState.hero(
                        icon: _upcoming
                            ? Icons.airplane_ticket_outlined
                            : Icons.history_outlined,
                        title: _upcoming
                            ? 'Aucun voyage à venir'
                            : 'Aucun voyage passé',
                        body: _upcoming
                            ? 'Vos prochaines réservations apparaîtront ici. Explorez les logements pour réserver.'
                            : 'Vos voyages terminés apparaîtront ici.',
                      ),
                    )
                  else
                    for (final r in filtered) ...[
                      TripCard(
                        reservation: r,
                        onTap: () => pushScreen(
                          context,
                          ReservationDetailScreen(
                            reservation: r,
                            viewerRole: ReservationViewerRole.locataire,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
