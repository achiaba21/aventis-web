import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

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
            color: AppColors.background,
          ),
        ),
        Gap(Espacement.gapItem),
        TextSeed("Asfar", fontSize: 21, fontWeight: FontWeight.bold),
      ],
    );
  }
}
