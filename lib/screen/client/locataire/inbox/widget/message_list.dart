import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/widget/message/message_tile.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final seances = Provider.of<AppData>(context).seance;
    return seances.isEmpty
        ? Center(child: TextSeed("Aucun element"))
        : ListView.builder(
          itemBuilder:
              (context, index) =>
                  Column(children: [MessageTile(seances[index]), Divider()]),
        );
  }
}
