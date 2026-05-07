import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/date/date_item.dart';
import 'package:asfar/widget/text/text_seed.dart';

class SejourSelector extends StatefulWidget {
  const SejourSelector({
    super.key,
    this.onSelectRange,
    this.selectedRange,
    this.appartementId,
  });

  final DateTimeRange? selectedRange;
  final void Function(DateTimeRange?)? onSelectRange;
  final int? appartementId; // Pour activer le calendrier d'occupation

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
          appartementId: widget.appartementId,
        ),
      ],
    );
  }
}
