import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class ListTileCustom extends StatelessWidget {
  const ListTileCustom({
    super.key,
    this.imageLeft,
    this.svgPathLeft,
    this.texte,
    this.imageRight = Icons.arrow_forward_ios_outlined,
    this.svgPathRight,
    this.onTap,
  });
  final void Function()? onTap;
  final String? texte;
  final String? svgPathLeft;
  final IconData? imageLeft;
  final String? svgPathRight;
  final IconData? imageRight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: Espacement.gapSection,

        children: [
          CircleIcon(svgPath: svgPathLeft, image: imageLeft, size: 18),
          Expanded(child: TextSeed(texte)),
          CircleIcon(svgPath: svgPathRight, image: imageRight, size: 18),
        ],
      ),
    );
  }
}
