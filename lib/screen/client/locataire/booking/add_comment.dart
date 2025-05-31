import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/booking/widget/start_rank.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/widget/button/plain_button_expand.dart';
import 'package:web_flutter/widget/clien_item/client_item_info.dart';
import 'package:web_flutter/widget/input/Input_zone.dart';
import 'package:web_flutter/widget/item/appart/appart_tile_item.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AddComment extends StatelessWidget {
  static String routeName = "addComment";
  const AddComment({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final Appartement appart = appData.selectedReservation!.appart!;
    return Scaffold(
      appBar: AppBar(title: TextSeed("Note et commentaire")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: Espacement.gapSection,
            children: [
              AppartTileItem(appart),
              Divider(),
              TextSeed("Note"),
              StartRank(onNote: (note) {}),
              Divider(),
              if (appData.client == null) ClientItemInfo(appData.client!),
              InputZone(placeHolder: "Votre commentaire"),
              Gap(Espacement.gapItem),
              PlainButtonExpand(value: "Envoyer"),
            ],
          ),
        ),
      ),
    );
  }
}
