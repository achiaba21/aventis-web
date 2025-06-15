import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/widget/notification/notification_tile.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = Provider.of<AppData>(context).notifs;
    return notifs.isEmpty
        ? Center(child: TextSeed("Aucun Element"))
        : ListView.builder(
          itemBuilder:
              (context, index) => NotificationTile(notif: notifs[index]),
        );
  }
}
