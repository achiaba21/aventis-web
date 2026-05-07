import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/button/texte_button.dart';
import 'package:asfar/widget/item/commentaire_item.dart';
import 'package:asfar/widget/item/start_progress.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartReview extends StatelessWidget {
  const AppartReview(this.appartement, {super.key});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    final note = appartement.note;
    final review = appartement.commentaires?.length ?? 0;
    final comment = appartement.commentaires?.firstOrNull;
    bool isPresent = comment != null;
    return Column(
      children: [
        Row(
          children: [
            StartProgress(fillPercentage: note),
            TextSeed("$note-$review reviews"),
            Spacer(),
            TexteButton(text: "tout voir"),
          ],
        ),
        if (isPresent) CommentaireItem(comment),
        if (!isPresent) TextSeed("Pas de commentaire"),
      ],
    );
  }
}
