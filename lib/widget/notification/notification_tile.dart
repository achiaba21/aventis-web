import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/notification.dart';
import 'package:web_flutter/widget/date/date_format.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key,this.notif});
  final Notification2? notif;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: Espacement.paddingBloc),
      child: Row(
        children: [
          CircleIcon(image: Icons.circle,),
          
          Expanded(
            child: Column(
              spacing: Espacement.gapSection,
              children: [
                Row(
                  spacing: Espacement.gapSection,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSeed(notif?.title),
                    DateFormat(date: DateTime.now()),
                  ],
                ),
                Row(
                  spacing: Espacement.gapSection,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSeed(notif?.contenu),
                    CircleIcon(image: Icons.arrow_forward_ios,),
                  ],
                ),
                
              ],
            ),
          )
        ],
      ),
    );
  }
}