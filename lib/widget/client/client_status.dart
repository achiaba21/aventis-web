import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/text/icon_text_2.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class ClientStatus extends StatefulWidget {
  const ClientStatus(this.client,{super.key});
  final Client? client;

  @override
  State<ClientStatus> createState() => _ClientStatusState();
}

class _ClientStatusState extends State<ClientStatus> {
  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    return Row(
      children: [
        ImageNet(client?.imgUrl),
        Expanded(
          child: Column(
            children: [
              Row(
                spacing: Espacement.gapItem,
                children: [
                  TextSeed(client?.fullName),
                  TextSeed(client?.nature),

                ],
              ),
              IconText2(image: Icons.circle,texte: "Actif maintenant",)
          
            ],
          ),
        )
      ],
    );
  }
}