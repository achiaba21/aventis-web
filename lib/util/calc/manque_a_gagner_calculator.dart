import 'package:asfar/model/calendar/calendar_plage.dart';

/// Calcule le « manque à gagner » potentiel sur un mois pour une annonce.
///
/// Formule (cf. business-spec §4.1) :
/// `(joursLibres + joursBloqués) × prixNuit`
///
/// - Jours « libres » = jours du mois non couverts par une plage occupée/en-attente.
/// - Jours « bloqués » = jours couverts par une plage `DISPONIBLE` (= blocage proprio
///   selon convention `CalendarPlage`).
/// - Les jours déjà réservés (`OCCUPE` / `EN_ATTENTE`) sont exclus.
///
/// Le « Manque à gagner » inclut volontairement les blocages : objectif métier
/// = inciter le proprio à débloquer ce qui peut l'être.
class ManqueAGagnerCalculator {
  ManqueAGagnerCalculator._();

  /// Retourne le manque à gagner pour un mois donné, exprimé en unité prix
  /// (généralement FCFA arrondi). Si [prixNuit] est nul ou négatif, retourne 0.
  static int computeForMonth({
    required List<CalendarPlage> plages,
    required int prixNuit,
    required int year,
    required int month,
  }) {
    if (prixNuit <= 0) return 0;
    final joursPotentiels = _joursPotentielsDuMois(plages, year, month);
    return joursPotentiels * prixNuit;
  }

  /// Compte les jours du mois où une réservation pourrait être faite ou
  /// débloquée — libres + bloqués proprio.
  static int _joursPotentielsDuMois(
    List<CalendarPlage> plages,
    int year,
    int month,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month, daysInMonth);

    final joursOccupes = <DateTime>{};
    for (final p in plages) {
      if (p.statut == PlageStatut.disponible) continue;
      var cursor = _dateOnly(p.debut);
      final end = _dateOnly(p.fin);
      while (cursor.isBefore(end)) {
        if (!cursor.isBefore(monthStart) && !cursor.isAfter(monthEnd)) {
          joursOccupes.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return daysInMonth - joursOccupes.length;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
