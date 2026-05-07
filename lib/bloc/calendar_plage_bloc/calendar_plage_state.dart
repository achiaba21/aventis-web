import 'package:asfar/model/calendar/calendar_plage.dart';

abstract class CalendarPlageState {}

class CalendarPlagesInitial extends CalendarPlageState {}

class CalendarPlagesLoading extends CalendarPlageState {}

class CalendarPlagesLoaded extends CalendarPlageState {
  final int appartId;
  final List<CalendarPlage> plages;
  final DateTime debut;
  final DateTime fin;

  CalendarPlagesLoaded({
    required this.appartId,
    required this.plages,
    required this.debut,
    required this.fin,
  });

  /// Retourne toutes les plages couvrant un jour donné.
  /// Supporte les plages superposées (plusieurs EN_ATTENTE concurrentes).
  List<CalendarPlage> getPlagesForDay(DateTime day) {
    return plages.where((p) => p.containsDay(day)).toList();
  }
}

class CalendarPlagesError extends CalendarPlageState {
  final String message;

  CalendarPlagesError(this.message);
}
