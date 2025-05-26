import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class CheckboxZone extends StatefulWidget {
  const CheckboxZone({
    super.key,
    required this.title,
    this.values = const [],
    this.selectedValues = const [],
  });

  final String? title;
  final List<String> values;
  final List<String> selectedValues;

  @override
  State<CheckboxZone> createState() => _CheckboxZoneState();
}

class _CheckboxZoneState extends State<CheckboxZone> {
  void toggle(String item) {
    setState(() {
      if (widget.selectedValues.contains(item)) {
        widget.selectedValues.remove(item);
      } else {
        widget.selectedValues.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(widget.title),
        ...List.generate(widget.values.length, (index) {
          final item = widget.values[index];
          bool inner = widget.selectedValues.contains(item);
          return InkWell(
            onTap: () => toggle(item),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSeed(item),
                Checkbox(
                  value: inner,
                  onChanged: (value) => toggle(item),
                  activeColor: Style.primaryColor,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
