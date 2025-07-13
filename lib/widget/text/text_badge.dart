import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

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
            Style.primaryColor.withAlpha(75),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: TextSeed(text, color: textColor ?? Style.primaryColor),
    );
  }
}
