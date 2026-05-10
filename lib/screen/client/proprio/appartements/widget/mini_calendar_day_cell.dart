import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cellule d'un jour du `MiniCalendarGrid`. Couleurs selon état :
/// - réservé : fond accent + texte onAccent w700
/// - en attente : fond accentSoft + texte accent
/// - bloqué : fond bgElev2 + texte text2 + border line
/// - aujourd'hui (et libre) : border 1.5 accent + texte accent
/// - libre : transparent + texte text
///
/// Le tap est désactivé pour les jours réservés/en-attente.
class MiniCalendarDayCell extends StatelessWidget {
  final int day;
  final bool isBooked;
  final bool isPending;
  final bool isBlocked;
  final bool isToday;
  final VoidCallback? onTap;

  const MiniCalendarDayCell({
    super.key,
    required this.day,
    required this.isBooked,
    required this.isPending,
    required this.isBlocked,
    required this.isToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color textColor;
    BoxBorder? border;
    FontWeight weight;

    if (isBooked) {
      background = AppColors.accent;
      textColor = AppColors.onAccent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w700;
    } else if (isPending) {
      background = AppColors.accentSoft;
      textColor = AppColors.accent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w500;
    } else if (isBlocked) {
      background = AppColors.bgElev2;
      textColor = AppColors.text2;
      border = Border.all(color: AppColors.line, width: 1);
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

    final canTap = !isBooked && !isPending && onTap != null;

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
