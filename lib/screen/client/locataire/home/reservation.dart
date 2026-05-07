import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:asfar/screen/client/locataire/home/widget/reservation/methode_payment.dart';
import 'package:asfar/screen/client/locataire/home/widget/reservation/totale_info.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/date/date_item.dart';
import 'package:asfar/widget/item/appart/appart_proprio_info.dart';
import 'package:asfar/widget/item/appart/appart_tile_item.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/theme/app_colors.dart';

class Reservation extends StatelessWidget {
  const Reservation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state is ReservationCreated) {
          // Succès : Afficher un message de confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Réservation créée avec succès ! En attente de validation du propriétaire.",
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );

          // Recharger les réservations de l'utilisateur
          context.read<ReservationBloc>().add(LoadUserReservations());

          // Nettoyer la réservation temporaire
          context.read<ReservationBloc>().add(ClearReservationReq());

          // Naviguer vers l'onglet Bookings
          navigateToBookings(context);
        } else if (state is ReservationError) {
          // Erreur : Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, state) {
          final req = state.currentReq;
          if (req == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("Aucune réservation en cours")),
            );
          }

          final appart = req.appartement!;
          final plage = req.plage!;

          return Scaffold(
            appBar: AppBar(),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  spacing: Espacement.gapItem,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: Espacement.gapItem,
                            children: [
                              AppartTileItem(appart),

                              //AppartProprioInfo(appart),
                              Divider(),
                              DateItem(selectedRange: plage, readOnly: true),
                              Divider(),
                              TotaleInfo(req),
                              Divider(),
                              MethodePayment(),
                              Divider(),
                              Gap(Espacement.gapSection * 5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppartBottom(
                  appartement: appart,
                  validationText:
                      state is ReservationLoading
                          ? "Réservation..."
                          : "Réserver",
                  onPress:
                      state is ReservationLoading
                          ? null
                          : () => _createReservation(context, req),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _createReservation(BuildContext context, ReservationReq req) {
    // Vérifier que le moyen de paiement est sélectionné
    if (req.moyenPaiement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez sélectionner un moyen de paiement"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Déclencher la création de la réservation
    context.read<ReservationBloc>().add(CreateReservation(req));
  }
}
