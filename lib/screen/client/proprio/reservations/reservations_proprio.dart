import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/reservations/widget/booking_item_proprio.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Page qui affiche les réservations reçues par le propriétaire
class ReservationsProprio extends StatefulWidget {
  const ReservationsProprio({super.key});

  @override
  State<ReservationsProprio> createState() => _ReservationsProprioState();
}

class _ReservationsProprioState extends State<ReservationsProprio> {
  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        // Afficher skeleton pendant le chargement initial (préchargement en cours)
        if (state is ReservationInitial) {
          return const ListShimmer(itemCount: 4);
        }

        // Gestion de l'état d'erreur (seulement si aucune donnée en cache)
        if (state is ReservationError && state.reservations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16),
                  TextSeed(
                    "Erreur de chargement",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  TextSeed(
                    state.message,
                    fontSize: 14,
                    color: AppColors.textMuted,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReservationBloc>().add(LoadProprietaireReservations());
                    },
                    child: TextSeed("Réessayer"),
                  ),
                ],
              ),
            ),
          );
        }

        // Gestion de l'état de chargement (afficher skeleton uniquement au premier chargement)
        if (state is ReservationLoading && state.reservations.isEmpty) {
          return const ListShimmer(itemCount: 4);
        }

        // Récupérer les réservations (disponibles dans tous les états grâce au pattern "keep last known data")
        final reservations = state.reservations;

        // Trier par date de création (plus récentes en premier)
        final sortedReservations = List.from(reservations)
          ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

        // Gestion de l'état vide
        if (sortedReservations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.inactive,
                  ),
                  SizedBox(height: 16),
                  TextSeed(
                    "Aucune réservation pour le moment",
                    fontSize: 16,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReservationBloc>().add(LoadProprietaireReservations());
                    },
                    child: TextSeed("Rafraîchir"),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: Espacement.gapSection,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSeed(
                      "${sortedReservations.length} réservation${sortedReservations.length > 1 ? 's' : ''}",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        context.read<ReservationBloc>().add(LoadProprietaireReservations());
                      },
                      tooltip: "Rafraîchir",
                    ),
                  ],
                ),
                ...sortedReservations.map((reservation) => BookingItemProprio(reservation)),
              ],
            ),
          ),
        );
      },
    );
  }
}
