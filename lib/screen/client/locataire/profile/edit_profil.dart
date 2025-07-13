import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/profile/widget/edit_photo.dart';
import 'package:web_flutter/widget/button/plain_button_expand.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class EditProfil extends StatelessWidget {
  static String routeName = "edit-profil";
  const EditProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: Espacement.gapItem,
            children: [
              EditPhoto("photo"),
              TextSeed("Informations personnelles"),
              Padding(
                padding: const EdgeInsets.all(8.0 * 4),
                child: Column(
                  spacing: Espacement.gapItem,
                  children: [
                    InputField(libelle: "Nom"),
                    InputField(libelle: "Prénom"),
                    InputField(libelle: "Email"),
                    InputField(libelle: "Téléphone"),
                    Gap(Espacement.gapSection),
                    PlainButtonExpand(value: "Enregistrer les changements"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
