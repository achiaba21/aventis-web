import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/booking/history.dart';
import 'package:asfar/screen/client/locataire/booking/widget/booking_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/texte_button.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion
        if (userState is! UserLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: TextSeed("Booking"),
              foregroundColor: AppColors.textPrimary,
            ),
            body: GuestLoginPrompt(
              message: "Connectez-vous pour accéder à vos réservations",
            ),
          );
        }

        // Utilisateur connecté : afficher les réservations normalement
        return Scaffold(
          appBar: AppBar(
            title: TextSeed("Booking"),
            foregroundColor: AppColors.textPrimary,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  // Forcer le rechargement
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

              // Afficher skeleton pendant le chargement initial (préchargement en cours)
              if (state is ReservationInitial) {
                return const ListShimmer(itemCount: 3);
              }

              // Gestion de l'état de chargement manuel (afficher skeleton pour cohérence UX)
              if (state is ReservationLoading && state is! ReservationLoaded) {
                return const ListShimmer(itemCount: 3);
              }

              // Récupérer les réservations (disponibles dans tous les états grâce au pattern "keep last known data")
              final reservations = state.reservations;

              // Trier par date de création (plus récentes en premier)
              final sortedReservations = List.from(reservations)..sort(
                (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                  a.createdAt ?? DateTime.now(),
                ),
              );

              // FILTRAGE OPTIONNEL : Afficher uniquement les réservations actives
              // Pour afficher TOUTES les réservations, mettez showOnlyActiveReservations = false
              const bool showOnlyActiveReservations = true;

              final displayedReservations =
                  showOnlyActiveReservations
                      ? sortedReservations.where((r) {
                        // Exclure les réservations terminées, annulées, refusées et finalisées
                        final status = r.statut ?? ReservationStatus.enAttente;
                        return status != ReservationStatus.terminee &&
                            status != ReservationStatus.annulee &&
                            status != ReservationStatus.refusee &&
                            status != ReservationStatus.finalisee;
                      }).toList()
                      : sortedReservations;

              // Gestion de l'état vide
              if (displayedReservations.isEmpty) {
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

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: Espacement.gapSection,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TexteButton(
                            text: "History",
                            onPressed: () => pushScreen(context, History()),
                          ),
                        ],
                      ),
                      ...displayedReservations.map(
                        (reservation) => BookingItem(reservation),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
