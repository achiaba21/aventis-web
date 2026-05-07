import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_view_mode.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/year_view.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/month_view.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/days_view.dart';

/// Vue zoomable du calendrier
///
/// Dispatche l'affichage selon le mode de vue actif :
/// - YEAR → YearView
/// - MONTH → MonthView
/// - DAYS → DaysView
class CalendarZoomableView extends StatelessWidget {
  const CalendarZoomableView({
    super.key,
    required this.mode,
    required this.currentDate,
    required this.reservations,
    required this.appartements,
    required this.colorPalette,
    this.onDateTapped,
    this.onMonthTapped,
    this.onReservationTapped,
  });

  final CalendarViewMode mode;
  final DateTime currentDate;
  final List<Reservation> reservations;
  final List<Appartement> appartements;
  final Map<int, Color> colorPalette;
  final Function(DateTime)? onDateTapped;
  final Function(int month)? onMonthTapped;
  final Function(Reservation)? onReservationTapped;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CalendarViewMode.year:
        return YearView(
          year: currentDate.year,
          reservations: reservations,
          colorPalette: colorPalette,
          onMonthTapped: onMonthTapped,
        );

      case CalendarViewMode.month:
        return SingleChildScrollView(
          child: MonthView(
            month: currentDate,
            reservations: reservations,
            colorPalette: colorPalette,
            onDayTapped: onDateTapped,
          ),
        );

      case CalendarViewMode.days:
        return DaysView(
          month: currentDate,
          reservations: reservations,
          appartements: appartements,
          colorPalette: colorPalette,
          onReservationTapped: onReservationTapped,
        );
    }
  }
}
