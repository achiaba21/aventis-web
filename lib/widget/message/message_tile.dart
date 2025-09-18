import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/screen/client/locataire/inbox/conversation.dart';
import 'package:web_flutter/widget/date/date_format.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(this.seance,{super.key});
  final Seance seance;
  @override
  Widget build(BuildContext context) {
    final client = seance.contact;
    final message = seance.last;

    return InkWell(
      onTap: () {
        // Navigation vers la conversation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Conversation(seance: seance),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Espacement.paddingBloc),
        child: Row(
          children: [
            CircleIcon(image: Icons.circle),
            ImageNet("name"),
            Expanded(
              child: Column(
                spacing: Espacement.gapSection,
                children: [
                  Row(
                    spacing: Espacement.gapSection,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextSeed(client?.fullName),
                      DateFormat(date: message.createdAt),
                    ],
                  ),
                  Row(
                    spacing: Espacement.gapSection,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: TextSeed(message.contenu, maxLines: 1)),
                      CircleIcon(image: Icons.arrow_forward_ios),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}