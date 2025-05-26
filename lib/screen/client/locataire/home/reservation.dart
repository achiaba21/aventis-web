import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
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

class Reservation extends StatelessWidget {
  const Reservation({super.key});
  static String routeName = "reservation";

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
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
          AppartBottom(
            onPress: () => relativePush(context, Disponibilite.routeName),
          ),
        ],
      ),
    );
  }
}
