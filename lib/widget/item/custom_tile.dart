import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    this.libelle,
    this.leftImage,
    this.leftSvgPath,
    this.rightImage,
    this.rightSvgPath,
    this.onPressed,
  });
  final String? libelle;
  final String? leftSvgPath;
  final IconData? leftImage;
  final String? rightSvgPath;
  final IconData? rightImage;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Espacement.gapSection,
      children: [
        if (leftImage != null || leftImage != null)
          CircleIcon(svgPath: leftSvgPath, image: leftImage, size: 12),
        TextSeed(libelle),
        Spacer(),
        IconBoutton(
          svgPath: rightSvgPath,
          icon: rightImage,
          onPressed: onPressed,
          size: 28,
        ),
      ],
    );
  }
}
