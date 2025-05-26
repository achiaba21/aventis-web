import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/login/login_screen.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class TextLogin extends StatelessWidget {
  const TextLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextSeed("Already have an account?"),
        Gap(Espacement.gapItem),
        TexteButton(
          text: "Sign in",
          onPressed: () => push(context, LoginScreen.routeName),
        ),
      ],
    );
  }
}
