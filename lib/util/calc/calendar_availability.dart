import 'package:asfar/model/calendar/calendar_plage.dart';

/// Helper pur pour déterminer si un jour est sélectionnable dans un picker
/// de dates, à partir des plages calendrier d'un appartement.
///
/// Règles :
/// - Un jour couvert par une plage `OCCUPE` ou `EN_ATTENTE` est **bloqué**
/// - Une plage `DISPONIBLE` (rare, surtout en blocage proprio) est aussi bloquée
/// - `selfExcludeRange` permet de garder sélectionnables les jours d'une plage
///   spécifique (cas typique : édition d'une réservation manuelle où l'on veut
///   pouvoir bouger les bornes sans être bloqué par sa propre plage)
///
/// La sémantique d'inclusion suit `CalendarPlage.containsDay` (borne `fin`
/// exclue, cf. jour de check-out libérable).
class CalendarAvailability {
  CalendarAvailability._();

  /// Retourne `true` si [day] est sélectionnable (libre).
  static bool isDayAvailable(
    DateTime day,
    List<CalendarPlage> plages, {
    DateTime? selfStart,
    DateTime? selfEnd,
  }) {
    final d = _dateOnly(day);
    final inSelf = selfStart != null &&
        selfEnd != null &&
        !d.isBefore(_dateOnly(selfStart)) &&
        d.isBefore(_dateOnly(selfEnd));

    for (final p in plages) {
      if (p.statut == PlageStatut.disponible) continue;
      if (p.containsDay(d)) {
        if (inSelf) continue;
        return false;
      }
    }
    return true;
  }

  /// Retourne `true` si la plage `[start, end[` n'intersecte aucune plage
  /// `OCCUPE` ou `EN_ATTENTE` (hors `selfStart/selfEnd`).
  ///
  /// Utile pour valider une sélection complète avant un POST.
  static bool isRangeAvailable(
    DateTime start,
    DateTime end,
    List<CalendarPlage> plages, {
    DateTime? selfStart,
    DateTime? selfEnd,
  }) {
    var cursor = _dateOnly(start);
    final last = _dateOnly(end);
    while (cursor.isBefore(last)) {
      if (!isDayAvailable(cursor, plages,
          selfStart: selfStart, selfEnd: selfEnd)) {
        return false;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  /// Taux d'occupation d'un mois : ratio de jours `OCCUPE` sur le nombre
  /// total de jours du mois. Retourne une valeur entre 0.0 et 1.0.
  ///
  /// Les plages `EN_ATTENTE` ne comptent pas (on ne mesure que l'occupation
  /// réelle, pas les promesses). Les plages `DISPONIBLE` (blocages proprio)
  /// non plus.
  static double occupancyRateForMonth(
    List<CalendarPlage> plages,
    DateTime month,
  ) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month, daysInMonth);

    final occupiedDays = <DateTime>{};
    for (final p in plages.where((p) => p.statut == PlageStatut.occupe)) {
      var cursor = _dateOnly(p.debut);
      final end = _dateOnly(p.fin);
      while (cursor.isBefore(end)) {
        if (!cursor.isBefore(monthStart) && !cursor.isAfter(monthEnd)) {
          occupiedDays.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    if (daysInMonth == 0) return 0;
    return occupiedDays.length / daysInMonth;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
