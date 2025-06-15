import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class ClientItemInfo extends StatelessWidget {
  const ClientItemInfo(this.client, {super.key});
  final Client client;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Espacement.gapItem,
      children: [ImageNet(client.imgUrl), TextSeed(client.fullName)],
    );
  }
}
