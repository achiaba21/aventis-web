import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/profile/widget/edit_photo.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

class EditProfil extends StatelessWidget {
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
                    PhoneInputField(),
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
