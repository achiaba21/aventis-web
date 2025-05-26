import 'package:flutter/material.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/offer_item.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartOffer extends StatelessWidget {
  const AppartOffer({super.key, required this.appartement});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    final offres = appartement.offres;
    bool mustShow = offres != null && offres.isNotEmpty;
    return Column(
      children: [
        TextSeed("Offres de l'appart"),
        if (!mustShow) TextSeed("Aucune données"),
        if (mustShow)
          GridView.count(
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children:
                appartement.offres!
                    .map((e) => OfferItem(commodite: e.commodite!))
                    .toList(),
          ),
      ],
    );
  }
}
