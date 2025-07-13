import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/profile/edit_profil.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/document/doc_item.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AccountInformation extends StatelessWidget {
  static String routeName = "account-info";
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppData>(context);
    final client = state.client;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: Espacement.gapItem,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBoutton(
            icon: Icons.arrow_back_ios,
            onPressed: () => back(context),
          ),
          ImageApp(client?.photoUser, size: 84),
          Gap(Espacement.gapItem),
          TextSeed("Hi , ${client?.fullName}"),
          TextSeed(client?.credential),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextSeed("Depuis date ${client?.createdAt?.year}"),
              IconBoutton(
                svgPath: "icon/profil/edit.svg",
                onPressed: () => relativePush(context, EditProfil.routeName),
              ),
            ],
          ),
          Gap(Espacement.gapItem),
          Divider(),
          Gap(Espacement.gapItem),
          TextSeed("Document"),
          Wrap(
            spacing: Espacement.gapSection,
            runSpacing: Espacement.gapItem,
            children: [DocItem(), DocItem()],
          ),
          Gap(Espacement.gapItem),
          Divider(),
          Gap(Espacement.gapItem),
          TexteButton(text: "Changer de mot de passe"),
        ],
      ),
    );
  }
}
