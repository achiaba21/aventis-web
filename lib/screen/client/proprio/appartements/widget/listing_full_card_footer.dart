import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_ghost_button.dart';
import 'package:asfar/theme/app_colors.dart';

/// Footer 3 boutons ghost (Calendrier / Modifier / Stats) d'une
/// `ListingFullCard`.
class ListingFullCardFooter extends StatelessWidget {
  final VoidCallback? onCalendarTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onStatsTap;

  const ListingFullCardFooter({
    super.key,
    this.onCalendarTap,
    this.onEditTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: ListingFullCardGhostButton(
              icon: Icons.calendar_today_outlined,
              label: 'Calendrier',
              onTap: onCalendarTap,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ListingFullCardGhostButton(
              icon: Icons.edit_outlined,
              label: 'Modifier',
              onTap: onEditTap,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ListingFullCardGhostButton(
              icon: Icons.bar_chart_outlined,
              label: 'Stats',
              onTap: onStatsTap,
            ),
          ),
        ],
      ),
    );
  }
}
