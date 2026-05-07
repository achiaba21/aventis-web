import 'package:asfar/model/calendar/calendar_stats.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Helper pour calculer les statistiques du calendrier
class CalendarStatsHelper {
  /// Calcule le taux d'occupation pour une période donnée
  ///
  /// Formule : (nombre de jours occupés / nombre de jours total) × 100
  /// Exclut les réservations annulées
  ///
  /// Paramètres :
  /// - [startDate] : Date de début de la période
  /// - [endDate] : Date de fin de la période
  /// - [reservations] : Liste des réservations
  ///
  /// Retourne un double entre 0.0 et 1.0
  static double calculateOccupancyRate(
    DateTime startDate,
    DateTime endDate,
    List<Reservation> reservations,
  ) {
    // Normaliser les dates (uniquement jour/mois/année)
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    // Calculer le nombre total de jours
    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) return 0.0;

    // Compter les jours occupés (en évitant les doublons)
    final Set<String> occupiedDays = {};

    for (final reservation in reservations) {
      // Ignorer les réservations annulées
      if (reservation.statut == ReservationStatus.annulee) continue;
      if (reservation.debut == null || reservation.fin == null) continue;

      // Normaliser les dates de réservation
      final resStart =
          DateTime(reservation.debut!.year, reservation.debut!.month, reservation.debut!.day);
      final resEnd =
          DateTime(reservation.fin!.year, reservation.fin!.month, reservation.fin!.day);

      // Ajouter chaque jour de la réservation qui est dans la période
      DateTime currentDay = resStart;
      while (currentDay.isBefore(resEnd) || currentDay.isAtSameMomentAs(resEnd)) {
        if ((currentDay.isAfter(start) || currentDay.isAtSameMomentAs(start)) &&
            (currentDay.isBefore(end) || currentDay.isAtSameMomentAs(end))) {
          // Format : YYYY-MM-DD
          occupiedDays.add('${currentDay.year}-${currentDay.month}-${currentDay.day}');
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }

    return occupiedDays.length / totalDays;
  }

  /// Retourne les réservations avec arrivée à une date donnée
  static List<Reservation> getArrivalsForDate(
    DateTime date,
    List<Reservation> reservations,
  ) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return reservations.where((r) {
      if (r.debut == null) return false;
      if (r.statut == ReservationStatus.annulee) return false;

      final arrivalDate = DateTime(r.debut!.year, r.debut!.month, r.debut!.day);
      return arrivalDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Retourne les réservations avec départ à une date donnée
  static List<Reservation> getDeparturesForDate(
    DateTime date,
    List<Reservation> reservations,
  ) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return reservations.where((r) {
      if (r.fin == null) return false;
      if (r.statut == ReservationStatus.annulee) return false;

      final departureDate = DateTime(r.fin!.year, r.fin!.month, r.fin!.day);
      return departureDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Compte le nombre de réservations en attente
  static int getPendingReservationsCount(List<Reservation> reservations) {
    return reservations
        .where((r) => r.statut == ReservationStatus.enAttente)
        .length;
  }

  /// Calcule les statistiques pour aujourd'hui
  static CalendarStats calculateTodayStats(List<Reservation> reservations) {
    final today = DateTime.now();

    return CalendarStats(
      occupancyRate: calculateOccupancyRate(
        DateTime(today.year, today.month, 1),
        DateTime(today.year, today.month + 1, 0),
        reservations,
      ),
      pendingCount: getPendingReservationsCount(reservations),
      arrivalsToday: getArrivalsForDate(today, reservations),
      departuresToday: getDeparturesForDate(today, reservations),
    );
  }

  /// Calcule les statistiques pour un mois donné
  static CalendarStats calculateMonthStats(
    DateTime month,
    List<Reservation> reservations,
  ) {
    final today = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return CalendarStats(
      occupancyRate: calculateOccupancyRate(
        firstDay,
        lastDay,
        reservations,
      ),
      pendingCount: getPendingReservationsCount(reservations),
      arrivalsToday: getArrivalsForDate(today, reservations),
      departuresToday: getDeparturesForDate(today, reservations),
    );
  }

  /// Détecte les conflits de dates pour un appartement
  ///
  /// Paramètres :
  /// - [startDate] : Date de début de la nouvelle réservation
  /// - [endDate] : Date de fin de la nouvelle réservation
  /// - [appartementId] : ID de l'appartement
  /// - [existingReservations] : Liste des réservations existantes
  ///
  /// Retourne true si un conflit est détecté
  static bool detectConflicts(
    DateTime startDate,
    DateTime endDate,
    int appartementId,
    List<Reservation> existingReservations,
  ) {
    return existingReservations.any((r) {
      // Ignorer si pas le même appartement
      if (r.appart?.id != appartementId) return false;

      // Ignorer si réservation annulée
      if (r.statut == ReservationStatus.annulee) return false;

      // Ignorer si dates manquantes
      if (r.debut == null || r.fin == null) return false;

      // Vérifier chevauchement :
      // Conflit si : startDate < r.fin ET endDate > r.debut
      return startDate.isBefore(r.fin!) && endDate.isAfter(r.debut!);
    });
  }

  /// Retourne les réservations en conflit avec une période donnée
  static List<Reservation> getConflictingReservations(
    DateTime startDate,
    DateTime endDate,
    int appartementId,
    List<Reservation> existingReservations,
  ) {
    return existingReservations.where((r) {
      if (r.appart?.id != appartementId) return false;
      if (r.statut == ReservationStatus.annulee) return false;
      if (r.debut == null || r.fin == null) return false;

      return startDate.isBefore(r.fin!) && endDate.isAfter(r.debut!);
    }).toList();
  }
}
