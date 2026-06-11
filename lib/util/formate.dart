import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';

String formateTime(DateTime? time) {
  if (time == null) {
    return "";
  }
  return "${time.day}-${time.month}-${time.year}";
}

String formateDate(DateTime? time,{int level=0}) {
  if (time == null) {
    return "";
  }
  switch (level) {
    case -1:
      return "${time.hour}:${time.minute}";
    case 0:
      return "${time.day}-${time.month}";
    case 1:
      return "${time.day}-${time.month}-${time.year}";
    default:
      return "${time.day}-${time.month}-${time.year} ${time.hour}:${time.minute}";
  }
}

String enumeration(int num) {
  if (num == 1) {
    return "1er";
  }
  return "$num";
}

String formateRangeTime(DateTimeRange? range) {
  if (range == null) {
    return "";
  }
  final first = range.start;
  final last = range.end;
  final fmonth = first.month - 1;
  final lmonth = last.month - 1;

  if (first.year == last.year && first.month == last.month) {
    return "Du ${enumeration(first.day)}-${last.day} ${month[fmonth]} ${last.year}";
  } else if (first.year == last.year) {
    return "Du ${enumeration(first.day)} ${month[fmonth]} au ${enumeration(last.day)} ${month[lmonth]} ${first.year}";
  }
  return "Du ${enumeration(last.day)} ${month[fmonth]} ${first.year} au ${enumeration(last.day)} ${month[lmonth]} ${last.year}";
}

String formateRangeTimeShort(DateTimeRange? range) {
  if (range == null) {
    return "";
  }
  final first = range.start;
  final last = range.end;
  final fmonth = first.month - 1;
  final lmonth = last.month - 1;
  // final fin = 3;

  if (first.year == last.year && first.month == last.month) {
    return "${enumeration(first.day)}-${last.day} ${monthS[fmonth]} ${last.year}";
  } else if (first.year == last.year) {
    return "${enumeration(first.day)} ${monthS[fmonth]} au ${enumeration(last.day)} ${monthS[lmonth]} ${first.year}";
  }
  return "${enumeration(last.day)} ${monthS[fmonth]} ${first.year} au ${enumeration(last.day)} ${monthS[lmonth]} ${last.year}";
}

String helpAmountFormate(dynamic number, {bool sup = true, bool decim = true}) {
  //// deboger(tmp, "solde");
  final nb = number?.toString();
  if (nb == null || nb.toString().isEmpty) {
    return "";
  }
  String tmp = (double.parse(nb)).toStringAsFixed(2);
  if (!decim) {
    if (sup == true) {
      tmp = double.parse(tmp).round().toString();
    } else if (sup == false) {
      tmp = double.parse(tmp).floor().toString();
    }
  }

  String newChaine = "";
  final tmps = tmp.split('.');
  final tmp2 = tmps[0];
  int length = tmp2.length;
  final List<String> amountList = [];

  for (int i = (length - 1), j = 0; i >= 0; i--, j++) {
    if ((j) % 3 == 0) {
      amountList.add(' ');
    }
    amountList.add(tmp[i]);
  }

  for (final digit in amountList.reversed) {
    newChaine += digit;
  }

  newChaine = newChaine.trim();
  if (tmps.length == 2) {
    if (double.parse(tmps[1]) > 0) {
      newChaine += ".${tmps[1]}";
    }
  }
  return newChaine.trim();
}

DateTime? toDate(String? date){
if(date == null){
  return null;
}
try {
  return DateTime.parse(date);
} catch (e) {
  return null;
}
}

/// Jours de la semaine
const List<String> _jours = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// Formate une date au format JJ/MM/AAAA
String formateDateSlash(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// Formate une date avec le jour de la semaine
/// Ex: "Lundi 15/01/2025 à 12h"
String formateDateWithDay(DateTime? date, {String? heure}) {
  if (date == null) return '';
  final dayName = _jours[date.weekday - 1];
  final dateStr = formateDateSlash(date);
  return '$dayName $dateStr${heure != null ? ' à $heure' : ''}';
}

/// Formate une date avec heure complète
/// Ex: "15/01/2025 à 14:30"
String formateDateHeure(DateTime? date) {
  if (date == null) return '';
  final dateStr = formateDateSlash(date);
  final heureStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  return '$dateStr à $heureStr';
}

// ============================================================
// FORMATAGE DES DATES AVANCÉ
// ============================================================

/// Formate une date avec indicateur de statut (retard, à venir)
/// Ex: "15/01/2025" ou "15/01/2025 (En retard)" ou "15/01/2025 (À venir)"
String formatDateWithStatus(DateTime? date, {bool isLate = false, bool isUpcoming = false}) {
  if (date == null) return '';
  final dateStr = formateDateSlash(date);
  if (isLate) {
    return '$dateStr (En retard)';
  } else if (isUpcoming) {
    return '$dateStr (À venir)';
  }
  return dateStr;
}

/// Formate une période entre deux dates
/// Ex: "Du 01/01/2025 au 31/01/2025"
String formatPeriode(DateTime? debut, DateTime? fin) {
  if (debut == null || fin == null) return '';
  return 'Du ${formateDateSlash(debut)} au ${formateDateSlash(fin)}';
}

/// Formate une période de manière courte
/// Ex: "01/01 - 31/01/2025"
String formatPeriodeShort(DateTime? debut, DateTime? fin) {
  if (debut == null || fin == null) return '';
  if (debut.year == fin.year) {
    return '${debut.day.toString().padLeft(2, '0')}/${debut.month.toString().padLeft(2, '0')} - ${formateDateSlash(fin)}';
  }
  return '${formateDateSlash(debut)} - ${formateDateSlash(fin)}';
}

// ============================================================
// FORMATAGE POUR GRAPHIQUES
// ============================================================

/// Formate une valeur d'axe pour les graphiques
/// Ex: 1500000 → "1.5M", 1500 → "1.5K", 150 → "150"
String formatAxisValue(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
}

/// Formate un pourcentage
/// Ex: 0.156 → "15.6%"
String formatPourcentage(double? value, {int decimals = 1}) {
  if (value == null) return '';
  return '${(value * 100).toStringAsFixed(decimals)}%';
}

// ============================================================
// FORMATAGE DES DATES AVEC MOIS EN LETTRES
// ============================================================

/// Mois abrégés en français
const List<String> _monthsShort = [
  '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
  'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
];

/// Formate une date avec le mois en lettres abrégé
/// Ex: "15 Jan 2025"
String formatDateMonth(DateTime? date) {
  if (date == null) return '';
  return '${date.day} ${_monthsShort[date.month]} ${date.year}';
}

/// Formate une date avec statut détaillé (jours de retard/à venir)
/// Ex: "15 Jan 2025 (3j de retard)" ou "15 Jan 2025 (Dans 2j)"
String formatDateWithStatusDetailed(DateTime? date, {bool isLate = false, bool isUpcoming = false}) {
  if (date == null) return '';
  final formatted = formatDateMonth(date);

  if (isLate) {
    final days = DateTime.now().difference(date).inDays;
    return '$formatted (${days}j de retard)';
  }

  if (isUpcoming) {
    final days = date.difference(DateTime.now()).inDays;
    if (days == 0) return "$formatted (Aujourd'hui)";
    if (days == 1) return '$formatted (Demain)';
    return '$formatted (Dans ${days}j)';
  }

  return formatted;
}

/// Formate une date de manière relative (court)
/// Ex: "Aujourd'hui", "Demain", "Dans 3j", "En retard (5j)", ou "15/01/2025"
String formatDateRelative(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final diff = date.difference(now).inDays;

  if (diff < 0) {
    return 'En retard (${-diff}j)';
  } else if (diff == 0) {
    return "Aujourd'hui";
  } else if (diff == 1) {
    return 'Demain';
  } else if (diff <= 7) {
    return 'Dans ${diff}j';
  }

  return formateDateSlash(date);
}

// ============================================================
// NOMS DES MOIS COMPLETS
// ============================================================

/// Mois complets en français
const List<String> _monthsFull = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

/// Formate une période avec noms de mois complets
/// Ex: "Janvier 2025" ou "Janvier - Mars 2025"
String formatPeriodeFull(DateTime? debut, DateTime? fin) {
  if (debut == null || fin == null) return '';

  if (debut.month == fin.month && debut.year == fin.year) {
    return '${_monthsFull[debut.month - 1]} ${debut.year}';
  }
  return '${_monthsFull[debut.month - 1]} - ${_monthsFull[fin.month - 1]} ${fin.year}';
}