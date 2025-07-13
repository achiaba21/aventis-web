import 'package:flutter/material.dart';
import 'package:web_flutter/screen/client/locataire/inbox/widget/message_list.dart';
import 'package:web_flutter/screen/client/locataire/inbox/widget/notification_list.dart';
import 'package:web_flutter/service/providers/style.dart';

class Inbox extends StatelessWidget {
  static final String routeName = "/inbox";
  const Inbox({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Style.primaryColor;
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: color,
            indicatorColor: color,
            labelColor: color,
            overlayColor: WidgetStateColor.resolveWith((states) => color.withAlpha(75) ,),
            tabs: [Tab(text: "Message"), Tab(text: "Notification")]),
        ),
        body: TabBarView(children: [MessageList(), NotificationList()]),
      ),
    );
  }
}
