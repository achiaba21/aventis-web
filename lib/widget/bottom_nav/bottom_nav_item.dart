import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/notification/notification_badge.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    this.text,
    this.active = false,
    this.image,
    this.svgPath,
    this.badgeCount = 0,
  });
  final String? text;
  final String? svgPath;
  final IconData? image;
  final bool active;
  final int badgeCount;

  BottomNavItem copyWith({bool? active, int? badgeCount}) {
    return BottomNavItem(
      key: key,
      active: active ?? this.active,
      image: image,
      svgPath: svgPath,
      text: text,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = active ? AppColors.accent : AppColors.inactive;
    return Column(
      children: [
        if (image != null || svgPath != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleIcon(
                image: image,
                svgPath: svgPath,
                color: activeColor,
                size: 24,
              ),
              // Badge de notification
              if (badgeCount > 0)
                PositionedNotificationBadge(
                  count: badgeCount,
                  right: -8,
                  top: -8,
                ),
            ],
          ),
        if (text != null) ...[
          Gap(Espacement.gapItem),
          TextSeed(text, color: activeColor),
        ],
      ],
    );
  }
}
