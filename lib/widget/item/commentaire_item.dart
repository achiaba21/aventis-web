import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';
import 'package:web_flutter/widget/user_til.dart';

class CommentaireItem extends StatelessWidget {
  const CommentaireItem(this.commentaire, {super.key});
  final Commentaire commentaire;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Style.containerColor2,
        borderRadius: BorderRadius.circular(Espacement.paddingBloc),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.paddingBloc * 2,
      ),
      child: Column(
        children: [
          UserTilComment(commentaire),
          TextSeed(commentaire.contenu, maxLines: 20),
        ],
      ),
    );
  }
}
