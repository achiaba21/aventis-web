import 'package:flutter/material.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class ProfilUser extends StatelessWidget {
  const ProfilUser(this.client, {super.key});
  final User client;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ImageApp(client.imgUrl, size: 32),
        Column(children: [TextSeed(client.fullName), TextSeed(client.credential)]),
      ],
    );
  }
}
