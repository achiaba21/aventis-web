import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/screen/signup/role_selection_screen.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlainButton(
          value: "Connexion",
          plain: false,
          onPress: () => pushScreen(context, LoginScreen()),
        ),
        Gap(Espacement.gapItem),
        PlainButton(
          value: "Inscription",
          plain: true,
          onPress: () => pushScreen(context, const RoleSelectionScreen()),
        ),
      ],
    );
  }
}