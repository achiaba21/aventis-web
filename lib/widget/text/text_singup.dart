import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/signup/role_selection_screen.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/texte_button.dart';
import 'package:asfar/widget/text/text_seed.dart';

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
          onPressed: () => pushScreen(context, const RoleSelectionScreen()),
        ),
      ],
    );
  }
}
