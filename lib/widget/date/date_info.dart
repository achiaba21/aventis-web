import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/text/icon_text.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class DateInfo extends StatelessWidget {
  const DateInfo(this.dates, {super.key, this.onPressed});

  final DateTimeRange? dates;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: Espacement.gapItem,
          children: [
            IconText(image: Icons.calendar_month_outlined, text: "Dates"),
            TextSeed(formateRangeTimeShort(dates)),
          ],
        ),
        TexteButton(text: "Modifier", onPressed: onPressed),
      ],
    );
  }
}
