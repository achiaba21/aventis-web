import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ProprioTile extends StatelessWidget {
  const ProprioTile({super.key, this.proprio, this.hosted = false});
  final Proprietaire? proprio;
  final bool hosted;

  @override
  Widget build(BuildContext context) {
    deboger(proprio?.imgUrl);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Espacement.gapItem,
      children: [
        ImageNet(proprio?.imgUrl, size: 24),
        Column(
          spacing: Espacement.gapItem / 2,
          children: [
            if (hosted) TextSeed("Publié par :"),
            TextSeed(proprio?.prenom ?? "Inconnue", fontSize: 10),
          ],
        ),
      ],
    );
  }
}
