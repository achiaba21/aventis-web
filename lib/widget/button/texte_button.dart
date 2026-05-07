import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class TexteButton extends StatelessWidget {
  const TexteButton({
    super.key,
    this.image,
    this.onPressed,
    this.size = 32,
    this.svgPath,
    this.reverse = false,
    this.text,
    this.bgColor,
    this.fgColor,
    this.plain = false,
  });
  final void Function()? onPressed;
  final String? text;
  final String? svgPath;
  final IconData? image;
  final double size;
  final bool reverse;
  final bool plain;
  final Color? bgColor;
  final Color? fgColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      if (text != null) TextSeed(text, color: fgColor),
      if (image != null || svgPath != null)
        CircleIcon(image: image, svgPath: svgPath, size: size, color: fgColor),
    ];
    if (reverse) {
      children = children.reversed.toList();
    }
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: plain ? EdgeInsets.all(Espacement.paddingBloc) : null,
        decoration:
            plain ? BoxDecoration(color: bgColor ?? AppColors.accent) : null,
        child: Row(children: children),
      ),
    );
  }
}
