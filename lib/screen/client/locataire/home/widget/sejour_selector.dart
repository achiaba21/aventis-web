import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/date/date_item.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class SejourSelector extends StatefulWidget {
  const SejourSelector({super.key, this.onSelectRange, this.selectedRange});

  final DateTimeRange? selectedRange;
  final void Function(DateTimeRange?)? onSelectRange;

  @override
  State<SejourSelector> createState() => _SejourSelectorState();
}

class _SejourSelectorState extends State<SejourSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Espacement.gapSection,
      children: [
        TextSeed("Sejour"),
        DateItem(
          onSelectRange: widget.onSelectRange,
          selectedRange: widget.selectedRange,
        ),
      ],
    );
  }
}
