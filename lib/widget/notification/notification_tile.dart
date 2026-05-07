import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/widget/date/date_format.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, this.notif});
  final NotificationModel? notif;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Espacement.paddingBloc),
      child: Row(
        children: [
          CircleIcon(
            image: Icons.circle,
            color: notif?.lu == true ? AppColors.info : AppColors.textMuted,
          ),

          Expanded(
            child: Column(
              spacing: Espacement.gapSection,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: Espacement.gapSection,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: TextSeed(notif?.displayTitle)),
                    if (notif?.createdAt != null)
                      TextSeed(
                        DateFormatUtils.formatRelativeShort(notif!.createdAt!),
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
                Row(
                  spacing: Espacement.gapSection,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: TextSeed(notif?.contenu, maxLines: 2)),
                    CircleIcon(image: Icons.arrow_forward_ios),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
