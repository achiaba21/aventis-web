import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class InfoCancel extends StatelessWidget {
  const InfoCancel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIcon(image: Icons.calendar_month),
        Gap(Espacement.gapItem),
        TextSeed("Free cancellation after 24hr of booking"),
      ],
    );
  }
}
