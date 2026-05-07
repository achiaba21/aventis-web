import 'package:asfar/model/reservation/reservation.dart';

/// Statistiques du calendrier pour une période donnée
class CalendarStats {
  /// Taux d'occupation (0.0 à 1.0)
  final double occupancyRate;

  /// Nombre de réservations en attente
  final int pendingCount;

  /// Réservations avec arrivée aujourd'hui
  final List<Reservation> arrivalsToday;

  /// Réservations avec départ aujourd'hui
  final List<Reservation> departuresToday;

  const CalendarStats({
    required this.occupancyRate,
    required this.pendingCount,
    required this.arrivalsToday,
    required this.departuresToday,
  });

  /// Formate le taux d'occupation en pourcentage
  String get occupancyPercentage =>
      '${(occupancyRate * 100).toStringAsFixed(0)}%';

  /// Retourne true si il y a des arrivées aujourd'hui
  bool get hasArrivalsToday => arrivalsToday.isNotEmpty;

  /// Retourne true si il y a des départs aujourd'hui
  bool get hasDeparturesToday => departuresToday.isNotEmpty;

  /// Retourne le nombre total d'événements aujourd'hui
  int get todayEventsCount => arrivalsToday.length + departuresToday.length;
}
