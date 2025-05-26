import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

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
    final colors = color ?? Style.primaryColor;
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
            TextSeed(value, color: plain ? Style.containerColor2 : colors),
          ],
        ),
      ),
    );
  }
}
