import 'package:flutter/material.dart';
import 'package:web_flutter/model/user/proprietaire.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class ProrioImg extends StatelessWidget {
  const ProrioImg(this.proprio, {super.key});
  final Proprietaire proprio;

  @override
  Widget build(BuildContext context) {
    return Row(children: [ImageNet(proprio.imgUrl), TextSeed(proprio.nom)]);
  }
}
