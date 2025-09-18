import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/widget/item/start_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartTitreInfo extends StatelessWidget {
  const AppartTitreInfo(this.appart, {super.key});
  final Appartement appart;
  @override
  Widget build(BuildContext context) {
    final note = appart.note;
    final adresse = appart.residence?.address;
    final titre = appart.titre ?? "Appartement sans titre";
    final adresseDescription = adresse?.description ?? "Adresse non disponible";

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextSeed(titre)),
            TextSeed(note.toString()),
            Gap(Espacement.gapItem),
            StartProgress(fillPercentage: note),
          ],
        ),
        Gap(Espacement.gapItem),
        Align(
          alignment: Alignment.centerLeft,
          child: TextSeed(
            adresseDescription,
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
