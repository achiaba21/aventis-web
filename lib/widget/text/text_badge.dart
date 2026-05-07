import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class TextBadge extends StatelessWidget {
  const TextBadge({super.key, this.text, this.bgColor, this.textColor});
  final String? text;
  final Color? bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingInput,
        vertical: Espacement.gapItem,
      ),
      decoration: BoxDecoration(
        color:
            bgColor ??
            textColor?.withAlpha(75) ??
            AppColors.accent.withAlpha(75),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: TextSeed(text, color: textColor ?? AppColors.accent),
    );
  }
}
