import 'package:flutter/material.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/item/start_progress.dart';
import 'package:asfar/widget/text/text_seed.dart';

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
