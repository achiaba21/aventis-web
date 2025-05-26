import 'package:flutter/material.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class IconText2 extends StatelessWidget {
  const IconText2({super.key, this.image, this.svgPath, this.texte});
  final String? texte;
  final String? svgPath;
  final IconData? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [CircleIcon(svgPath: svgPath, image: image), TextSeed(texte)],
    );
  }
}
