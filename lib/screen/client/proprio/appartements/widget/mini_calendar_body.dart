import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_day_cell.dart';
import 'package:asfar/theme/app_colors.dart';

/// Grid 7×N du calendrier — header weekdays + cellules offset + cellules jours.
class MiniCalendarBody extends StatelessWidget {
  final DateTime currentMonth;
  final int daysInMonth;
  final int startOffset;
  final int? todayDay;
  final List<int> bookedDays;
  final List<int> pendingDays;
  final List<int> blockedDays;
  final void Function(DateTime day)? onDayTap;

  const MiniCalendarBody({
    super.key,
    required this.currentMonth,
    required this.daysInMonth,
    required this.startOffset,
    required this.todayDay,
    required this.bookedDays,
    required this.pendingDays,
    required this.blockedDays,
    this.onDayTap,
  });

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: [
        for (final w in _weekdays)
          Center(
            child: Text(
              w,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
              ),
            ),
          ),
        for (var i = 0; i < startOffset; i++) const SizedBox.shrink(),
        for (var d = 1; d <= daysInMonth; d++)
          MiniCalendarDayCell(
            day: d,
            isBooked: bookedDays.contains(d),
            isPending: pendingDays.contains(d),
            isBlocked: blockedDays.contains(d),
            isToday: todayDay == d,
            onTap: onDayTap == null
                ? null
                : () => onDayTap!(
                      DateTime(currentMonth.year, currentMonth.month, d),
                    ),
          ),
      ],
    );
  }
}
