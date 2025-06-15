import 'package:flutter/material.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/widget/client/client_status.dart';
import 'package:web_flutter/widget/message/message_item.dart';
import 'package:web_flutter/widget/message/send_message.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key,this.seance,});
  final Seance? seance;
  @override
  Widget build(BuildContext context) {
    final messages = seance?.message ?? [];

    return Scaffold(
      appBar: AppBar(
        title: ClientStatus(seance?.contact),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => MessageItem(messages[index]),),
            ),
            SendMessage(),
          ],
        ),
      ),
    );
  }
}