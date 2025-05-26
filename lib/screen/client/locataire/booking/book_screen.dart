import 'package:flutter/material.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/date/date_info.dart';
import 'package:web_flutter/widget/item/appart/appart_proprio_info.dart';
import 'package:web_flutter/widget/item/appart/appart_tile_item.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class BookScreen extends StatelessWidget {
  const BookScreen(this.reservation, {super.key});
  final Reservation reservation;
  @override
  Widget build(BuildContext context) {
    final appart = reservation.appart!;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          AppartTileItem(appart),
          Divider(),
          AppartProprioInfo(appart),
          Divider(),
          DateInfo(reservation.plage),
          Divider(),

          Row(
            children: [
              TexteButton(image: Icons.add, text: "Ajouter", onPressed: () {}),
              TextSeed("Noter et ajouter un commentaire"),
            ],
          ),
        ],
      ),
    );
  }
}
