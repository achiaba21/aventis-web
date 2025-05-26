import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.scale(
          scaleY: 0.98,
          child: CircleIcon(
            svgPath: "assets/icon/app_logo.svg",
            size: 87,
            color: Style.containerColor2,
          ),
        ),
        Gap(Espacement.gapItem),
        TextSeed("Asfar", fontSize: 21, fontWeight: FontWeight.bold),
      ],
    );
  }
}
