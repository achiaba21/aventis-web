import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/text/text_badge.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class DocItem extends StatelessWidget {
  const DocItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Style.containerColor2.withAlpha(25),
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
                color: Style.errorColor,
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
