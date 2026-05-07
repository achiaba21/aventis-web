import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/booking/widget/booking_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/texte_button.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations si elles ne sont pas déjà chargées
    final currentState = context.read<ReservationBloc>().state;
    if (currentState is ReservationInitial) {
      context.read<ReservationBloc>().add(LoadUserReservations());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextSeed("Historique des réservations"),
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<ReservationBloc>().add(LoadUserReservations());
            },
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      body: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, state) {
          // Gestion de l'état d'erreur
          if (state is ReservationError) {
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
                    TexteButton(
                      text: "Réessayer",
                      onPressed: () {
                        context.read<ReservationBloc>().add(
                          LoadUserReservations(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Afficher skeleton pendant le chargement
          if (state is ReservationInitial || state is ReservationLoading) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: ListShimmer(itemCount: 5),
            );
          }

          // Récupérer les réservations
          List<dynamic> reservations = [];
          if (state is ReservationLoaded) {
            reservations = state.reservations;
          }

          // Trier par date de création (plus anciennes en dernier pour afficher TOUT l'historique)
          final sortedReservations = List.from(reservations)..sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );

          // Gestion de l'état vide
          if (sortedReservations.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: AppColors.inactive),
                    SizedBox(height: 16),
                    TextSeed(
                      "Aucune réservation dans l'historique",
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    TextSeed(
                      "Vos réservations passées et actuelles apparaîtront ici",
                      fontSize: 14,
                      color: AppColors.textMuted,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    TexteButton(
                      text: "Rafraîchir",
                      onPressed: () {
                        context.read<ReservationBloc>().add(
                          LoadUserReservations(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Afficher TOUTES les réservations
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // En-tête avec compteur
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Espacement.paddingBloc,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextSeed(
                        "Total: ${sortedReservations.length} réservation${sortedReservations.length > 1 ? 's' : ''}",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                // Liste scrollable des réservations
                Expanded(
                  child: ListView.separated(
                    itemCount: sortedReservations.length,
                    separatorBuilder:
                        (context, index) =>
                            SizedBox(height: Espacement.gapSection),
                    itemBuilder: (context, index) {
                      return BookingItem(sortedReservations[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
