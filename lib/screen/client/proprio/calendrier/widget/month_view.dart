import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_day_cell.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Vue mois : affiche la grille de jours du mois (vue par défaut)
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.month,
    required this.reservations,
    required this.colorPalette,
    this.onDayTapped,
  });

  final DateTime month;
  final List<Reservation> reservations;
  final Map<int, Color> colorPalette;
  final Function(DateTime)? onDayTapped;

  static const List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête des jours de la semaine
        _buildWeekDaysHeader(),
        SizedBox(height: Espacement.gapSection),

        // Grille des jours
        _buildDaysGrid(),
      ],
    );
  }

  /// Construit l'en-tête avec les jours de la semaine
  Widget _buildWeekDaysHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays
          .map(
            (day) => SizedBox(
              width: 40,
              child: TextSeed(
                day,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  /// Construit la grille des jours du mois
  Widget _buildDaysGrid() {
    final days = _getDaysInMonth();
    final rows = <Widget>[];

    // Créer les lignes de 7 jours
    for (int i = 0; i < days.length; i += 7) {
      final rowDays = days.sublist(i, (i + 7).clamp(0, days.length));

      // Compléter la ligne si nécessaire
      while (rowDays.length < 7) {
        rowDays.add(null);
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: Espacement.gapItem),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowDays
                .map((date) => SizedBox(
                      width: 40,
                      height: 40,
                      child: date != null
                          ? _buildDayCell(date)
                          : const SizedBox.shrink(),
                    ))
                .toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  /// Construit une cellule de jour
  Widget _buildDayCell(DateTime date) {
    final isToday = _isToday(date);
    final isCurrentMonth = date.month == month.month;
    final occupationColors = _getOccupationColorsForDate(date);

    return CalendarDayCell(
      day: date.day,
      occupationColors: occupationColors,
      isToday: isToday,
      isCurrentMonth: isCurrentMonth,
      onTap: occupationColors.isNotEmpty
          ? () => onDayTapped?.call(date)
          : null,
    );
  }

  /// Retourne les jours à afficher dans la grille
  List<DateTime?> _getDaysInMonth() {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Jour de la semaine du premier jour (1 = lundi, 7 = dimanche)
    int startWeekday = firstDay.weekday;

    final days = <DateTime?>[];

    // Ajouter des cellules vides pour les jours avant le premier du mois
    for (int i = 1; i < startWeekday; i++) {
      // Ajouter les jours du mois précédent
      final prevMonthDay = firstDay.subtract(Duration(days: startWeekday - i));
      days.add(prevMonthDay);
    }

    // Ajouter les jours du mois
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    // Ajouter des jours du mois suivant pour compléter la dernière ligne
    int remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        final nextMonthDay = lastDay.add(Duration(days: i));
        days.add(nextMonthDay);
      }
    }

    return days;
  }

  /// Vérifie si une date est aujourd'hui
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Retourne les couleurs des appartements occupés pour une date
  List<Color> _getOccupationColorsForDate(DateTime date) {
    final colors = <Color>[];

    for (final reservation in reservations) {
      // Ignorer les réservations annulées
      if (reservation.statut == ReservationStatus.annulee) continue;

      // Vérifier si la date est dans la période de réservation
      if (reservation.debut != null &&
          reservation.fin != null &&
          reservation.appart?.id != null) {
        final start =
            DateTime(reservation.debut!.year, reservation.debut!.month, reservation.debut!.day);
        final end = DateTime(reservation.fin!.year, reservation.fin!.month, reservation.fin!.day);
        final targetDate = DateTime(date.year, date.month, date.day);

        if ((targetDate.isAfter(start) || targetDate.isAtSameMomentAs(start)) &&
            (targetDate.isBefore(end) || targetDate.isAtSameMomentAs(end))) {
          // Ajouter la couleur de l'appartement
          final color = colorPalette[reservation.appart!.id];
          if (color != null && !colors.contains(color)) {
            colors.add(color);
          }
        }
      }
    }

    return colors;
  }
}
