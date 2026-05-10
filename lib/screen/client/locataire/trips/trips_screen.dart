import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/screen/client/locataire/trips/widget/trip_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/mapping/reservation_to_trip.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran "Mes voyages" du Locataire — V8.5 branché sur `ReservationBloc`.
///
/// Reproduit `LocataireTrips` du proto : chips à venir / passés + liste
/// de [TripCard] avec footer actions sur les voyages à venir.
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
            final trips =
                ReservationToTripMapper.mapMany(state.reservations);
            final isInitialLoading =
                state is ReservationLoading && trips.isEmpty;
            final isErrorWithoutCache =
                state is ReservationError && trips.isEmpty;

            if (isInitialLoading) return _buildLoading();
            if (isErrorWithoutCache) {
              return EmptyState.error(
                message: state.message,
                onRetry: _onRetry,
              );
            }
            return _buildContent(trips);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 60, 18, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 130),
    );
  }

  Widget _buildContent(List<TripCardData> trips) {
    final upcomingCount = trips.where((t) => t.upcoming).length;
    final pastCount = trips.length - upcomingCount;
    final filtered = trips.where((t) => t.upcoming == _upcoming).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AsfarChip(
                label: 'À venir ($upcomingCount)',
                active: _upcoming,
                onTap: () => setState(() => _upcoming = true),
              ),
              const SizedBox(width: 8),
              AsfarChip(
                label: 'Passés ($pastCount)',
                active: !_upcoming,
                onTap: () => setState(() => _upcoming = false),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: EmptyState.hero(
                icon: _upcoming
                    ? Icons.airplane_ticket_outlined
                    : Icons.history_outlined,
                title: _upcoming ? 'Aucun voyage à venir' : 'Aucun voyage passé',
                body: _upcoming
                    ? 'Vos prochaines réservations apparaîtront ici. Explorez les logements pour réserver.'
                    : 'Vos voyages terminés apparaîtront ici.',
              ),
            )
          else
            for (final t in filtered) ...[
              TripCard(
                listing: t.listing,
                status: t.status,
                dates: t.dates,
                code: t.code,
                upcoming: t.upcoming,
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}
