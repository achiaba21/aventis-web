import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/text/text_badge.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class DocItem extends StatelessWidget {
  const DocItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(25),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Espacement.gapSection,
            children: [
              TextSeed("Information 1"),
              IconBoutton(
                svgPath: "icon/profil/trash.svg",
                color: AppColors.error,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Espacement.gapSection * 3,

            children: [TextBadge(text: "Status"), TextSeed("type")],
          ),
        ],
      ),
    );
  }
}
