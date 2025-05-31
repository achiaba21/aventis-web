import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/screen/client/locataire/booking/add_comment.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/plain_button_icon.dart';
import 'package:web_flutter/widget/date/date_info.dart';
import 'package:web_flutter/widget/item/appart/appart_proprio_info.dart';
import 'package:web_flutter/widget/item/appart/appart_tile_item.dart';
import 'package:web_flutter/widget/item/commentaire_item.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class BookScreen extends StatelessWidget {
  static String routeName = "bookScreen";
  const BookScreen(this.reservation, {super.key});
  final Reservation reservation;
  @override
  Widget build(BuildContext context) {
    final appart = reservation.appart!;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: Espacement.gapItem,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppartTileItem(appart),
                    Divider(),
                    AppartProprioInfo(appart),
                    Divider(),
                    DateInfo(reservation.plage),
                    Divider(),
                    TextSeed("Review"),
                    if (appart.commentaires != null &&
                        appart.commentaires!.isNotEmpty)
                      CommentaireItem(appart.commentaires!.first),
                    Row(
                      children: [
                        PlainButtonIcon(
                          image: Icons.add,
                          value: "Ajouter",
                          onPress: () {
                            relativePush(context, AddComment.routeName);
                          },
                        ),
                        TextSeed("Noter et ajouter un commentaire"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppartBottom(validationText: "Archiver", reservation: reservation),
        ],
      ),
    );
  }
}
