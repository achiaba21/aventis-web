import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    super.key,
    this.svgPath,
    this.image,
    this.size = 42,
    this.color,
    this.neutral = false,
    this.bgColor = Colors.transparent,
  });
  final String? svgPath;
  final IconData? image;
  final double size;
  final bool neutral;
  final Color? color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final innerColor = color ?? Style.iconColor;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Espacement.circle),
      ),
      child:
          svgPath != null
              ? SvgPicture.asset(
                width: size,
                height: size,
                svgPath!,
                colorFilter:
                    neutral
                        ? null
                        : ColorFilter.mode(innerColor, BlendMode.srcIn),
              )
              : image != null
              ? Icon(image!, color: innerColor, size: size)
              : null,
    );
  }
}
