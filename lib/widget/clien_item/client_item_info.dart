import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/client.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';

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
