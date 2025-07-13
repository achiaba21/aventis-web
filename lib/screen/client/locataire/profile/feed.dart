import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/plain_button_expand.dart';
import 'package:web_flutter/widget/input/Input_zone.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Feed extends StatelessWidget {
  static String routeName = "feed";
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: Espacement.gapSection,
        children: [
          Row(
            spacing: Espacement.gapSection,
            children: [
              IconBoutton(
                icon: Icons.arrow_back_ios,
                onPressed: () => back(context),
                size: 14,
              ),
              Gap(Espacement.gapSection * 2),
              TextSeed("FeedBack"),
            ],
          ),
          Divider(),
          Gap(Espacement.gapSection),
          InputField(libelle: "Titre (optionnel)"),
          InputZone(libelle: "Dites en plus"),
          PlainButtonExpand(value: "Envoyer votre avis"),
        ],
      ),
    );
  }
}
