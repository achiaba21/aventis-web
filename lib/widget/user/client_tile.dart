import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/client.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Widget qui affiche les informations d'un client/locataire (utilisé par les propriétaires)
class ClientTile extends StatelessWidget {
  const ClientTile({super.key, this.client});
  final Client? client;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Espacement.gapItem,
      children: [
        ImageNet(client?.imgUrl, size: 24),
        Column(
          spacing: Espacement.gapItem / 2,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSeed(client?.prenom ?? "Client", fontSize: 10),
          ],
        ),
      ],
    );
  }
}
