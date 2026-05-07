import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/item/appart/appart_localisation.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartTileItem extends StatelessWidget {
  const AppartTileItem(this.appartement, {super.key});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Espacement.gapItem,
      children: [
        Expanded(
          child: ImageNet(
            appartement.photos?.firstOrNull?.path,
            height: 120,
            radius: Espacement.radius,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(appartement.titre),
              AppartLocalisation(address: appartement.address),
            ],
          ),
        ),
      ],
    );
  }
}
