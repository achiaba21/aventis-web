abstract class CalendarPlageEvent {}

class LoadCalendarPlages extends CalendarPlageEvent {
  final int appartId;
  final DateTime? debut;
  final DateTime? fin;

  /// Si true → endpoint démarcheur, sinon endpoint propriétaire
  final bool isDemarcheur;

  LoadCalendarPlages({
    required this.appartId,
    this.debut,
    this.fin,
    this.isDemarcheur = true,
  });
}

/// Recharge les plages avec les mêmes paramètres que le dernier chargement
class RefreshCalendarPlages extends CalendarPlageEvent {}
