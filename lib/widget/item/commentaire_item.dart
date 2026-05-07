import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/commentaire/commentaire.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/user_til.dart';
import 'package:asfar/theme/app_colors.dart';

class CommentaireItem extends StatelessWidget {
  const CommentaireItem(this.commentaire, {super.key});
  final Commentaire commentaire;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
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
