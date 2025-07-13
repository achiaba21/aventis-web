import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/item/appart/appart_localisation.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartTileItem extends StatelessWidget {
  const AppartTileItem(this.appartement, {super.key});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Espacement.gapItem,
      children: [
        Expanded(child: ImageNet(appartement.imgUrl)),
        Expanded(
          child: Column(
            children: [
              TextSeed(appartement.titre),
              AppartLocalisation(address: appartement.residence?.address),
            ],
          ),
        ),
      ],
    );
  }
}
