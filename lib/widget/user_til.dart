import 'package:flutter/material.dart';
import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class UserTilComment extends StatelessWidget {
  const UserTilComment(this.comment, {super.key});
  final Commentaire comment;

  @override
  Widget build(BuildContext context) {
    final client = comment.client!;
    final img = client.imgUrl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          child: img == null ? CircleIcon(image: Icons.person) : ImageNet(img),
        ),
        Column(
          children: [
            TextSeed(client.fullName),
            TextSeed("${comment.createdAt}"),
          ],
        ),
      ],
    );
  }
}
