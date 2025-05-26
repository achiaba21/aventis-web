import 'package:flutter/material.dart';
import 'package:web_flutter/model/residence/commodite/commodite.dart';
import 'package:web_flutter/widget/text/icon_text.dart';

class OfferItem extends StatelessWidget {
  const OfferItem({super.key, required this.commodite});
  final Commodite commodite;

  @override
  Widget build(BuildContext context) {
    return IconText(
      svgPath: commodite.svgPath,
      image: commodite.icon,
      text: commodite.nom,
    );
  }
}
