import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';

class Separate extends StatelessWidget {
  const Separate({super.key, this.data});
  final String? data;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Gap(Espacement.gapItem),
        TextSeed(data),
        Gap(Espacement.gapItem),
        Expanded(child: Divider()),
      ],
    );
  }
}
