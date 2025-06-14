import 'package:flutter/material.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class DateFormat extends StatelessWidget {
  const DateFormat({super.key, this.date,this.level=-1});
  final DateTime? date;
  final int level;

  @override
  Widget build(BuildContext context) {
    return TextSeed(formateDate(date,level: level));
  }
}