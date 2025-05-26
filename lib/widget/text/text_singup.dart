import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/signup/signup.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class TextSingup extends StatelessWidget {
  const TextSingup({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextSeed("Do not have an account?"),
        Gap(Espacement.gapItem),
        TexteButton(
          text: "Sign up",
          onPressed: () => push(context, Signup.routeName),
        ),
      ],
    );
  }
}
