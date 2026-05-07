import 'package:flutter/material.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Utilitaires pour le formatage et la manipulation des dates
class DateFormatUtils {
  /// Formate une date de manière relative (Il y a X min/h, Hier, etc.)
  /// avec l'heure pour les dates plus anciennes
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // Moins d'une minute
    if (difference.inSeconds < 60) {
      return 'Maintenant';
    }
    // Moins d'une heure
    else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    }
    // Moins de 24 heures
    else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    }
    // Hier
    else if (difference.inDays == 1) {
      return "Hier à $timeStr";
    }
    // Cette semaine (moins de 7 jours)
    else if (difference.inDays < 7) {
      final weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      final weekday = weekdays[date.weekday - 1];
      return "$weekday à $timeStr";
    }
    // Date complète
    else {
      final months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
      return "${date.day} ${months[date.month - 1]} ${date.year} à $timeStr";
    }
  }

  /// Formate une date de manière relative courte (5min, 2h, 3j)
  static String formatRelativeShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  /// Formate uniquement l'heure avec padding (09:05)
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formate une date courte (15/03)
  static String formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  /// Formate une date complète (15/03/2025)
  static String formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class DateFormat extends StatelessWidget {
  const DateFormat({super.key, this.date,this.level=-1});
  final DateTime? date;
  final int level;

  @override
  Widget build(BuildContext context) {
    return TextSeed(formateDate(date,level: level));
  }
}