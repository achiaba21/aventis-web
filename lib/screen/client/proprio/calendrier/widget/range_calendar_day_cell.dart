import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cellule d'un jour du `RangeCalendarPicker` (wizard réservation manuelle).
///
/// Couleurs selon état :
/// - jour bloqué (réservation existante / blocage proprio) → bgElev2 + texte
///   text2 barré, non tappable (rouge léger pour signaler le conflit)
/// - extrémité de la sélection (start ou end) → accent plein + onAccent w700
/// - jour entre start et end → accentSoft + accent
/// - aujourd'hui (et libre) → border accent
/// - libre → texte text neutre
class RangeCalendarDayCell extends StatelessWidget {
  final int day;
  final bool isUnavailable;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final bool isToday;
  final VoidCallback? onTap;

  const RangeCalendarDayCell({
    super.key,
    required this.day,
    required this.isUnavailable,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    BoxBorder? border;
    FontWeight weight;
    TextDecoration decoration = TextDecoration.none;

    if (isUnavailable) {
      background = AppColors.errorLight;
      textColor = AppColors.danger;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w400;
      decoration = TextDecoration.lineThrough;
    } else if (isStart || isEnd) {
      background = AppColors.accent;
      textColor = AppColors.onAccent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w700;
    } else if (isInRange) {
      background = AppColors.accentSoft;
      textColor = AppColors.accent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w500;
    } else if (isToday) {
      background = Colors.transparent;
      textColor = AppColors.accent;
      border = Border.all(color: AppColors.accent, width: 1.5);
      weight = FontWeight.w500;
    } else {
      background = Colors.transparent;
      textColor = AppColors.text;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w500;
    }

    final canTap = !isUnavailable && onTap != null;
    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: weight,
              color: textColor,
              decoration: decoration,
            ),
          ),
        ),
      ),
    );
  }
}
