import 'package:asfar/model/calendar/calendar_plage.dart';

/// Suggestion calculée d'optimisation de revenus pour le proprio.
///
/// Affichée dans le bandeau « Conseil » du `CalendarBookingsScreen`.
class TipSuggestion {
  /// Nombre de jours à ouvrir suggéré.
  final int joursOuvrables;

  /// Gain potentiel estimé (FCFA arrondi).
  final int gainPotentielFcfa;

  const TipSuggestion({
    required this.joursOuvrables,
    required this.gainPotentielFcfa,
  });
}

/// Moteur d'heuristique pour le bandeau Conseil (cf. business-spec §4.2).
///
/// V1 (semaine en cours, lundi → dimanche) :
/// 1. Compte les jours « libres » dans la semaine (= ni occupés, ni en attente).
/// 2. Si `joursLibres >= seuilJoursLibres` → retourne une suggestion.
/// 3. Sinon retourne `null` (pas de bandeau).
///
/// Gain estimé = `min(joursLibres, 4) × prixNuit × tauxOccupationMoyen`.
/// Si `tauxOccupationHistorique` n'est pas fourni → fallback 70 %.
class TipSuggestionEngine {
  TipSuggestionEngine._();

  /// Seuil minimum de jours libres dans la semaine pour afficher le conseil.
  static const int seuilJoursLibres = 4;

  /// Plafond de jours suggérés (réaliste).
  static const int joursMaxSuggeres = 4;

  /// Taux d'occupation moyen utilisé en fallback sans historique.
  static const double tauxOccupationMoyenFallback = 0.70;

  /// Calcule la suggestion pour la semaine courante de [now].
  ///
  /// Retourne `null` si moins de [seuilJoursLibres] jours libres dans la semaine
  /// ou si [prixNuit] est non positif.
  ///
  /// [now] injectable pour les tests (par défaut : `DateTime.now()`).
  static TipSuggestion? computeForCurrentWeek({
    required List<CalendarPlage> plages,
    required int prixNuit,
    double? tauxOccupationHistorique,
    DateTime? now,
  }) {
    if (prixNuit <= 0) return null;
    final ref = _dateOnly(now ?? DateTime.now());
    final weekStart = _startOfWeek(ref);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final joursLibres = _joursLibresEntre(plages, weekStart, weekEnd);
    if (joursLibres < seuilJoursLibres) return null;

    final n = joursLibres < joursMaxSuggeres ? joursLibres : joursMaxSuggeres;
    final taux = tauxOccupationHistorique ?? tauxOccupationMoyenFallback;
    final gain = (n * prixNuit * taux).round();
    return TipSuggestion(joursOuvrables: n, gainPotentielFcfa: gain);
  }

  /// Compte les jours dans `[start, end[` non couverts par une plage occupée
  /// ou en attente. Les plages `DISPONIBLE` (blocage proprio) comptent comme
  /// libres — objectif : inciter à débloquer.
  static int _joursLibresEntre(
    List<CalendarPlage> plages,
    DateTime start,
    DateTime end,
  ) {
    final joursReserves = <DateTime>{};
    for (final p in plages) {
      if (p.statut == PlageStatut.disponible) continue;
      var cursor = _dateOnly(p.debut);
      final pEnd = _dateOnly(p.fin);
      while (cursor.isBefore(pEnd)) {
        if (!cursor.isBefore(start) && cursor.isBefore(end)) {
          joursReserves.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    final totalJours = end.difference(start).inDays;
    return totalJours - joursReserves.length;
  }

  /// Lundi 00:00 de la semaine de [d].
  static DateTime _startOfWeek(DateTime d) {
    final dayOnly = _dateOnly(d);
    // weekday : lundi = 1, dimanche = 7
    final daysFromMonday = dayOnly.weekday - 1;
    return dayOnly.subtract(Duration(days: daysFromMonday));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
