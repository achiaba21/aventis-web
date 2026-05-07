import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class PlainButtonIcon extends StatelessWidget {
  const PlainButtonIcon({
    super.key,
    this.color,
    this.value,

    this.onPress,

    this.image,
    this.svgPath,
  });

  final String? value;
  final Color? color;
  final void Function()? onPress;
  final String? svgPath;
  final IconData? image;

  @override
  Widget build(BuildContext context) {
    final colors = color ?? AppColors.accent;
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc / 2,
          vertical: Espacement.paddingInput / 2,
        ),
        decoration: BoxDecoration(
          color: colors.withAlpha(100),
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Espacement.gapSection,
          children: [
            TextSeed(value, color: colors, fontSize: 10),
            CircleIcon(svgPath: svgPath, size: 16, image: image, color: colors),
          ],
        ),
      ),
    );
  }
}
