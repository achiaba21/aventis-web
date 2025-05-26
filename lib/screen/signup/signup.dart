import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/button/custom_button.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/input/input_pass.dart';
import 'package:web_flutter/widget/logo.dart';
import 'package:web_flutter/widget/text/text_login.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Signup extends StatelessWidget {
  static final String routeName = "/signup";
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.containerColor3,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/logo/logo.png"),
            opacity: 0.1,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Logo(),
              TextSeed("Signup page"),
              Gap(Espacement.gapSection),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      placeHolder: "Ex :07",
                      libelle: "Telephone",
                      keyboardType: TextInputType.number,
                    ),
                    Gap(Espacement.gapItem),
                    InputField(placeHolder: "mail", libelle: "Email"),
                    Gap(Espacement.gapItem),
                    InputPass(libelle: "Mot de passe"),
                    Gap(Espacement.gapItem),
                    InputPass(libelle: "Confirmer mot de passe"),
                    Gap(Espacement.gapSection),
                    CustomButton(text: "Continue", onPressed: () => 2),
                  ],
                ),
              ),

              Spacer(),
              TextLogin(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
