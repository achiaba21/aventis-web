import 'package:flutter/material.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';

class IconBoutton extends StatelessWidget {
  const IconBoutton({
    super.key,
    this.icon,
    this.onPressed,
    this.svgPath,
    this.color,
    this.bgColor,
    this.neutral = false,
    this.size = 24,
  });
  final IconData? icon;
  final String? svgPath;
  final Color? color;
  final Color? bgColor;
  final bool neutral;
  final double size;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: CircleIcon(
        image: icon,
        svgPath: svgPath,
        color: color,
        neutral: neutral,
        size: size,
        bgColor: bgColor ?? Colors.transparent,
      ),
    );
  }
}
