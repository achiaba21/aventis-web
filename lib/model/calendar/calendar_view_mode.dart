/// Mode de vue du calendrier global
enum CalendarViewMode {
  /// Vue année : affiche les 12 mois de l'année
  year,

  /// Vue mois : affiche la grille de jours du mois (vue par défaut)
  month,

  /// Vue jours : affiche le détail des jours avec timeline
  days,
}

/// Extension pour ajouter des méthodes utilitaires
extension CalendarViewModeExtension on CalendarViewMode {
  /// Retourne true si on peut zoomer davantage
  bool get canZoomIn {
    return this != CalendarViewMode.days;
  }

  /// Retourne true si on peut dézoomer
  bool get canZoomOut {
    return this != CalendarViewMode.year;
  }

  /// Retourne le prochain niveau de zoom (ou null si niveau max)
  CalendarViewMode? get nextZoomLevel {
    switch (this) {
      case CalendarViewMode.year:
        return CalendarViewMode.month;
      case CalendarViewMode.month:
        return CalendarViewMode.days;
      case CalendarViewMode.days:
        return null;
    }
  }

  /// Retourne le niveau de dézoom précédent (ou null si niveau min)
  CalendarViewMode? get previousZoomLevel {
    switch (this) {
      case CalendarViewMode.days:
        return CalendarViewMode.month;
      case CalendarViewMode.month:
        return CalendarViewMode.year;
      case CalendarViewMode.year:
        return null;
    }
  }

  /// Retourne le titre de la vue
  String get title {
    switch (this) {
      case CalendarViewMode.year:
        return 'Vue Année';
      case CalendarViewMode.month:
        return 'Vue Mois';
      case CalendarViewMode.days:
        return 'Vue Jours';
    }
  }
}
