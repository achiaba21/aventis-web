import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/date/date_format.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key});

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
                    TextSeed("data"),
                    DateFormat(date: DateTime.now()),
                  ],
                ),
                Row(
                  spacing: Espacement.gapSection,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSeed("Nouveau message recus"),
                    CircleIcon(image: Icons.arrow_forward_ios,),
                  ],
                ),
                
              ],
            ),
          )
        ],
      ),
    );;
  }
}