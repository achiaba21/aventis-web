import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    this.text,
    this.active = false,
    this.image,
    this.svgPath,
  });
  final String? text;
  final String? svgPath;
  final IconData? image;
  final bool active;

  BottomNavItem copyWith({bool? active}) {
    return BottomNavItem(
      key: key,
      active: active ?? this.active,
      image: image,
      svgPath: svgPath,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = active ? Style.primaryColor : Style.innactiveColor;
    return Column(
      children: [
        if (image != null || svgPath != null)
          CircleIcon(
            image: image,
            svgPath: svgPath,
            color: activeColor,
            size: 24,
          ),
        if (text != null) ...[
          Gap(Espacement.gapItem),
          TextSeed(text, color: activeColor),
        ],
      ],
    );
  }
}
