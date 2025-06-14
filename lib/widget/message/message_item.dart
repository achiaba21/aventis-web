import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/message/message.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MessageItem extends StatelessWidget {
  const MessageItem(this.message,{super.key});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(Espacement.gapItem),
          child: TextSeed(message.contenu,maxLines: 10,),
        ),
      ],
    );
  }
}