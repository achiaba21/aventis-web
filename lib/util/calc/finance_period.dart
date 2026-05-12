/// Période d'agrégation pour les écrans financiers du proprio.
///
/// La page Finances permet à l'utilisateur de naviguer dans le temps via :
/// 1. Un sélecteur d'année (`year`)
/// 2. Un switcher de granularité (`FinancePeriod`)
/// 3. Une navigation chevrons sur la période sélectionnée (`index`)
///
/// L'`index` est :
/// - pour `week` : 0..52 (semaine ISO dans l'année)
/// - pour `month` : 0..11 (mois calendaire 0-indexé)
/// - pour `quarter` : 0..3 (T1=0, T2=1, T3=2, T4=3)
enum FinancePeriod {
  week,
  month,
  quarter;

  /// Libellé affiché dans le switcher.
  String get switcherLabel {
    switch (this) {
      case FinancePeriod.week:
        return 'Semaine';
      case FinancePeriod.month:
        return 'Mois';
      case FinancePeriod.quarter:
        return 'Trimestre';
    }
  }

  /// Date de début de la période [index] dans l'[year].
  DateTime startOf(int year, int index) {
    switch (this) {
      case FinancePeriod.week:
        // Semaine ISO : commence le lundi. Semaine 0 = celle qui contient
        // le 1er janvier (clampée).
        final jan1 = DateTime(year, 1, 1);
        // Décalage pour atteindre le lundi de la semaine 0
        final daysFromMonday = jan1.weekday - 1;
        final week0Monday =
            jan1.subtract(Duration(days: daysFromMonday));
        return week0Monday.add(Duration(days: index * 7));
      case FinancePeriod.month:
        return DateTime(year, index + 1, 1);
      case FinancePeriod.quarter:
        return DateTime(year, index * 3 + 1, 1);
    }
  }

  /// Date de fin (inclusive) de la période [index] dans l'[year].
  DateTime endOf(int year, int index) {
    switch (this) {
      case FinancePeriod.week:
        final start = startOf(year, index);
        return start.add(const Duration(days: 6, hours: 23, minutes: 59));
      case FinancePeriod.month:
        return DateTime(year, index + 2, 0, 23, 59, 59);
      case FinancePeriod.quarter:
        return DateTime(year, (index + 1) * 3 + 1, 0, 23, 59, 59);
    }
  }

  /// Vérifie si [date] tombe dans la période [index] de l'[year].
  bool contains(int year, int index, DateTime date) {
    final start = startOf(year, index);
    final end = endOf(year, index);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Nombre max d'index possibles dans une année donnée (semaines varient
  /// 52/53, mois toujours 12, trimestres toujours 4).
  int maxIndex(int year) {
    switch (this) {
      case FinancePeriod.week:
        // Compte les semaines de l'année — last week start ≤ 31 déc.
        final dec31 = DateTime(year, 12, 31);
        var weeks = 52;
        for (var i = 52; i <= 53; i++) {
          final s = startOf(year, i);
          if (!s.isAfter(dec31)) weeks = i;
        }
        return weeks;
      case FinancePeriod.month:
        return 11;
      case FinancePeriod.quarter:
        return 3;
    }
  }

  /// Retourne l'index de la période contenant [date] dans l'[year].
  /// Suppose que [date].year == [year] (sinon, clamp aux bornes).
  int indexOf(int year, DateTime date) {
    if (date.year < year) return 0;
    if (date.year > year) return maxIndex(year);
    switch (this) {
      case FinancePeriod.week:
        for (var i = 0; i <= maxIndex(year); i++) {
          if (contains(year, i, date)) return i;
        }
        return maxIndex(year);
      case FinancePeriod.month:
        return date.month - 1;
      case FinancePeriod.quarter:
        return (date.month - 1) ~/ 3;
    }
  }

  /// Libellé affiché dans le header (« Nov. 2026 », « T4 2026 », « Sem. 45 »).
  String periodLabel(int year, int index) {
    switch (this) {
      case FinancePeriod.week:
        return 'Sem. ${index + 1}';
      case FinancePeriod.month:
        return _monthsShort[index];
      case FinancePeriod.quarter:
        return 'T${index + 1}';
    }
  }

  /// Libellé long (« Novembre 2026 », « 4ᵉ trimestre 2026 », « Semaine du 5 nov »).
  String longLabel(int year, int index) {
    switch (this) {
      case FinancePeriod.week:
        final start = startOf(year, index);
        return 'Semaine du ${start.day} ${_monthsFull[start.month - 1]}';
      case FinancePeriod.month:
        return '${_monthsFull[index]} $year';
      case FinancePeriod.quarter:
        return '${index + 1}ᵉ trimestre $year';
    }
  }

  /// Libellé de la période précédente (utile pour « vs. octobre »).
  String previousPeriodLongLabel(int year, int index) {
    final prev = previousAnchor(year, index);
    return longLabel(prev.year, prev.index);
  }

  /// Retourne l'anchor de la période précédente (peut changer d'année).
  ({int year, int index}) previousAnchor(int year, int index) {
    if (index > 0) return (year: year, index: index - 1);
    final prevYear = year - 1;
    return (year: prevYear, index: maxIndex(prevYear));
  }

  /// Retourne l'anchor de la période suivante (peut changer d'année).
  ({int year, int index}) nextAnchor(int year, int index) {
    if (index < maxIndex(year)) return (year: year, index: index + 1);
    return (year: year + 1, index: 0);
  }
}

const _monthsShort = [
  'Janv.', 'Févr.', 'Mars', 'Avr.', 'Mai', 'Juin',
  'Juil.', 'Août', 'Sept.', 'Oct.', 'Nov.', 'Déc.',
];

const _monthsFull = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];
