import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/date/date_item.dart';
import 'package:web_flutter/widget/filtered/checkbox_zone.dart';
import 'package:web_flutter/widget/filtered/custom_range.dart';
import 'package:web_flutter/widget/filtered/quantity_information.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class FilterOption extends StatefulWidget {
  const FilterOption({super.key});

  @override
  State<FilterOption> createState() => _FilterOptionState();
}

class _FilterOptionState extends State<FilterOption> {
  double max = 10000000;
  double min = 0;
  int litqte = 0;
  int chambeqte = 0;
  int doucheqte = 0;
  DateTimeRange? selectedRange;
  List<String> commodite = [];
  List<String> preference = [];
  List<String> regle = [];

  late RangeValues range;

  void reset() {
    setState(() {
      commodite = [];
      preference = [];
      regle = [];
      litqte = 0;
      chambeqte = 0;
      doucheqte = 0;
      selectedRange = null;
      range = RangeValues(min, max);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    range = RangeValues(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final start = range.start.ceil();
    final end = range.end.ceil();
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Style.containerColor3,
            boxShadow: [
              BoxShadow(
                color: Style.shadowColor,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconBoutton(icon: Icons.close, onPressed: () => back(context)),
              Spacer(),
              PlainButton(
                value: "Reset",
                plain: false,
                color: Style.white,
                onPress: reset,
              ),
              Gap(Espacement.gapSection),
              PlainButton(value: "Save", onPress: () => back(context)),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Espacement.gapSection,
                      children: [
                        TextSeed("Prix"),
                        Gap(Espacement.gapSection),
                        TextSeed(
                          "${helpAmountFormate(start)} FCFA - ${helpAmountFormate(end)} FCFA",
                        ),
                        CustomRange(
                          range: range,
                          onChange: onChange,
                          max: max,
                          min: min,
                        ),
                        Gap(Espacement.gapItem),
                        Divider(),
                        DateItem(
                          selectedRange: selectedRange,
                          onSelectRange:
                              (p0) => setState(() {
                                selectedRange = p0;
                              }),
                        ),
                        Divider(),
                        Gap(Espacement.gapSection),
                        TextSeed("Lit et Chambre"),
                        Gap(Espacement.gapSection),
                        QuantityInformation(
                          title: "Lit",
                          maxValue: 5,
                          selectedValue: litqte,
                          onSelectedValue:
                              (value) => setState(() {
                                litqte = value;
                              }),
                        ),
                        QuantityInformation(
                          title: "Chambre",
                          maxValue: 5,
                          selectedValue: chambeqte,
                          onSelectedValue:
                              (value) => setState(() {
                                chambeqte = value;
                              }),
                        ),
                        QuantityInformation(
                          title: "Douche",
                          maxValue: 5,
                          selectedValue: doucheqte,
                          onSelectedValue:
                              (value) => setState(() {
                                doucheqte = value;
                              }),
                        ),
                        CheckboxZone(
                          title: "Commodite",
                          values: amenities,
                          selectedValues: commodite,
                        ),
                        CheckboxZone(
                          title: "Preference",
                          values: roomPreferences,
                          selectedValues: preference,
                        ),
                        CheckboxZone(
                          title: "Règle",
                          values: rules,
                          selectedValues: regle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onChange(RangeValues ranges) {
    deboger(ranges);
    setState(() {
      range = ranges;
    });
  }
}
