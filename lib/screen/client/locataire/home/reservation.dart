import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_bloc.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_event.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/home/disponibilite.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/info_cancel.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/reservation/methode_payment.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/reservation/totale_info.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/date/date_info.dart';
import 'package:web_flutter/widget/item/appart/appart_proprio_info.dart';
import 'package:web_flutter/widget/item/appart/appart_tile_item.dart';
import 'package:web_flutter/model/request/reservation_req.dart';

class Reservation extends StatelessWidget {
  const Reservation({super.key});
  static String routeName = "reservation";

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          // Succès : Aller à la page de confirmation
          relativePush(context, Disponibilite.routeName);
        } else if (state is BookingError) {
          // Erreur : Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Consumer<AppData>(
        builder: (context, appData, child) {
          final req = appData.req!;
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
                              Divider(),
                              AppartProprioInfo(appart),
                              Divider(),
                              InfoCancel(),
                              Divider(),
                              DateInfo(plage),
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
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    return AppartBottom(
                      appartement: appart,
                      validationText: state is BookingLoading ? "Réservation..." : "Réserver",
                      onPress: state is BookingLoading ? null : () => _createBooking(context, req),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _createBooking(BuildContext context, ReservationReq req) {
    // Vérifier que le moyen de paiement est sélectionné
    if (req.moyenPaiement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez sélectionner un moyen de paiement"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Déclencher la création du booking
    context.read<BookingBloc>().add(CreateBooking(req));
  }
}
