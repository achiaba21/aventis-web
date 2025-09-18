import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/home/owner_appartements_screen.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartProprioInfo extends StatelessWidget {
  const AppartProprioInfo(this.appart, {super.key});

  final Appartement appart;

  @override
  Widget build(BuildContext context) {
    final prorio = appart.residence?.proprietaire;
    final img = prorio?.imgUrl;
    final nbComment = appart.commentaires?.length ?? 0;
    final nomProprietaire = prorio?.nom ?? "Propriétaire anonyme";

    return GestureDetector(
      onTap: () {
        final proprietaireId = prorio?.id;
        if (proprietaireId != null) {
          relativePush(
            context,
            OwnerAppartementsScreen.routeName,
            extra: {'proprietaireId': proprietaireId, 'proprietaireNom': nomProprietaire},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Espacement.paddingInput),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextSeed("Publié par $nomProprietaire"),
                      Gap(4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  Gap(Espacement.gapItem / 2),
                  TextSeed(
                    "$nbComment commentaire${nbComment > 1 ? 's' : ''}",
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: img == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : Image.asset(img, errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, color: Colors.grey[600]);
                    }),
            ),
          ],
        ),
      ),
    );
  }
}
