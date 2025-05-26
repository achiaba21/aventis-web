import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class QuantityInformation extends StatelessWidget {
  const QuantityInformation({
    super.key,
    this.title,
    required this.maxValue,
    this.selectedValue = 0,
    required this.onSelectedValue,
  });
  final String? title;
  final int maxValue;
  final int selectedValue;
  final void Function(int value) onSelectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Espacement.gapSection,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(title),
        Row(
          spacing: Espacement.gapSection,
          children: [
            ...List.generate(maxValue + 1, (index) {
              String value = "";
              bool first = index == 0;
              if (first) {
                value = "Any";
              } else {
                value = index.toString();
              }
              bool active = selectedValue == index;
              double poid = active ? 2 : 0;
              return InkWell(
                onTap: () => onSelectedValue(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 + poid,
                    vertical: 10 + poid,
                  ),
                  decoration: BoxDecoration(
                    color: active ? Style.primaryColor : null,
                    border:
                        active
                            ? null
                            : Border.all(
                              color: Style.white.withAlpha(125),
                              width: 2,
                            ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextSeed(value),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
