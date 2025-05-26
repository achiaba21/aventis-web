import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/custom_button.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/input/input_pass.dart';
import 'package:web_flutter/widget/item/login_social.dart';
import 'package:web_flutter/widget/logo.dart';
import 'package:web_flutter/widget/separate.dart';
import 'package:web_flutter/widget/text/text_seed.dart';
import 'package:web_flutter/widget/text/text_singup.dart';

class LoginScreen extends StatelessWidget {
  static final String routeName = "/login";

  const LoginScreen({super.key});

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Logo(),
              TextSeed("Login page"),
              Gap(Espacement.gapSection),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputField(
                      placeHolder: "Ex :07",
                      libelle: "Telephone",
                      keyboardType: TextInputType.number,
                    ),
                    Gap(Espacement.gapItem),
                    InputPass(libelle: "Mot de passe"),
                    Gap(Espacement.gapSection),
                    CustomButton(
                      text: "Continue",
                      onPressed: () => push(context, Explore.routeName),
                    ),
                    Gap(Espacement.gapSection),
                    Separate(data: "Ou"),
                    TextSeed("Sign up with"),
                    Gap(Espacement.gapItem),
                    LoginSocial(),
                  ],
                ),
              ),

              Spacer(),
              TextSingup(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
