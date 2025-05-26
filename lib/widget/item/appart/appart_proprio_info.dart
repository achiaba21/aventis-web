import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartProprioInfo extends StatelessWidget {
  const AppartProprioInfo(this.appart, {super.key});

  final Appartement appart;

  @override
  Widget build(BuildContext context) {
    final prorio = appart.residence?.proprietaire;
    final img = prorio?.imgUrl;
    final nbComment = appart.commentaires?.length;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Espacement.paddingInput),
      child: Row(
        children: [
          Column(
            children: [
              TextSeed("Publié par ${prorio?.nom}"),
              TextSeed("$nbComment"),
            ],
          ),
          Spacer(),
          CircleAvatar(
            child: img == null ? Icon(Icons.person) : Image.asset(img),
          ),
        ],
      ),
    );
  }
}
