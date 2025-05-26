import 'package:flutter/material.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/widget/item/start_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Note extends StatelessWidget {
  const Note(this.note, {super.key});
  final double? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StartProgress(fillPercentage: note ?? 0),
        TextSeed(helpAmountFormate(note)),
      ],
    );
  }
}
