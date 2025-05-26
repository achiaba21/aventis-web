import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';

class LoginSocial extends StatelessWidget {
  const LoginSocial({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBoutton(svgPath: "assets/icon/tweeter.svg", neutral: true),
        Gap(Espacement.gapItem),
        IconBoutton(svgPath: "assets/icon/google.svg", neutral: true),
        Gap(Espacement.gapItem),
        IconBoutton(svgPath: "assets/icon/facebook.svg", neutral: true),
      ],
    );
  }
}
