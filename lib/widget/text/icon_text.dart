import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    this.color,
    this.image,
    this.svgPath,
    this.text,
    this.size = 16,
  });
  final String? text;
  final String? svgPath;
  final IconData? image;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Espacement.gapItem,
      children: [
        CircleIcon(
          svgPath: svgPath,
          image: image,
          size: size,
          color: color ?? AppColors.textPrimary,
        ),
        TextSeed(text, color: color),
      ],
    );
  }
}
