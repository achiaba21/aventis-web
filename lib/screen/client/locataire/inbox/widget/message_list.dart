import 'package:flutter/material.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/widget/message/message_tile.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final seances = List.generate(7, (index) => Seance(

    ),);
    return ListView.builder(itemBuilder: (context, index) => Column(
      children: [
        MessageTile(seances[index]),
        Divider(),
      ],
    ),);
  }
}