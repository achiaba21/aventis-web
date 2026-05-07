import 'package:asfar/model/user/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/booking/booking.dart';
import 'package:asfar/screen/client/locataire/booking/widget/start_rank.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/clien_item/client_item_info.dart';
import 'package:asfar/widget/input/Input_zone.dart';
import 'package:asfar/widget/item/appart/appart_tile_item.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AddComment extends StatelessWidget {
  const AddComment({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final appart = reservation.appart;

    return Scaffold(
      appBar: AppBar(title: TextSeed("Note et commentaire")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: Espacement.gapSection,
            children: [
              if (appart != null) AppartTileItem(appart),
              Divider(),
              TextSeed("Note"),
              StartRank(onNote: (note) {}),
              Divider(),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded && state.user != null) {
                    return ClientItemInfo(state.user as Client);
                  }
                  return SizedBox.shrink();
                },
              ),
              InputZone(placeHolder: "Votre commentaire"),
              Gap(Espacement.gapItem),
              PlainButtonExpand(
                value: "Envoyer",
                onPress: () => pushScreen(context, Booking()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
