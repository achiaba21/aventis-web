import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cellule de jour du `AppartCalendarRangePicker`.
///
/// Étend les états du `MiniCalendarDayCell` du proprio avec 3 états dédiés
/// au range picking : bornes de sélection (`isStart` / `isEnd`) et jour
/// intérieur du range (`isInRange`).
///
/// Hiérarchie d'affichage (du plus prioritaire au moins) :
/// 1. `isBooked` / `isPending` → fond rouge/orange, non-tappable
/// 2. `isStart` / `isEnd` → pastille pleine accent, w700
/// 3. `isInRange` → fond accentSoft, accent
/// 4. `isToday` → border accent
/// 5. libre → texte neutre
class RangePickerDayCell extends StatelessWidget {
  final int day;
  final bool isBooked;
  final bool isPending;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final bool isToday;
  final bool isPast;
  final VoidCallback? onTap;

  const RangePickerDayCell({
    super.key,
    required this.day,
    required this.isBooked,
    required this.isPending,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.isToday,
    required this.isPast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    BoxBorder border = Border.all(color: Colors.transparent);
    FontWeight weight = FontWeight.w500;

    if (isBooked) {
      background = AppColors.accent.withValues(alpha: 0.85);
      textColor = AppColors.onAccent;
      weight = FontWeight.w700;
    } else if (isPending) {
      background = AppColors.warn.withValues(alpha: 0.25);
      textColor = AppColors.warn;
      weight = FontWeight.w600;
    } else if (isStart || isEnd) {
      background = AppColors.accent;
      textColor = AppColors.onAccent;
      weight = FontWeight.w700;
    } else if (isInRange) {
      background = AppColors.accentSoft;
      textColor = AppColors.accent;
      weight = FontWeight.w600;
    } else if (isToday) {
      background = Colors.transparent;
      textColor = AppColors.accent;
      border = Border.all(color: AppColors.accent, width: 1.5);
    } else if (isPast) {
      background = Colors.transparent;
      textColor = AppColors.text3;
    } else {
      background = Colors.transparent;
      textColor = AppColors.text;
    }

    final canTap = !isBooked && !isPending && !isPast && onTap != null;

    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(fontSize: 12, fontWeight: weight, color: textColor),
        ),
      ),
    );
  }
}
