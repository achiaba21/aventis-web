import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

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
            plain ? BoxDecoration(color: bgColor ?? Style.primaryColor) : null,
        child: Row(children: children),
      ),
    );
  }
}
