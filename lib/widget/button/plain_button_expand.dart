import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class PlainButtonExpand extends StatelessWidget {
  const PlainButtonExpand({
    super.key,
    this.color,
    this.value,
    this.plain = true,
    this.onPress,
  });

  final String? value;
  final Color? color;
  final bool plain;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    final colors = color ?? AppColors.accent;
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc / 2,
          vertical: Espacement.paddingInput,
        ),
        decoration: BoxDecoration(
          color: plain ? colors : null,
          border: Border.all(color: colors),
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextSeed(value, color: plain ? AppColors.background : colors),
          ],
        ),
      ),
    );
  }
}
