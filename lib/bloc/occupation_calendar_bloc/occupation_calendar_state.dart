import 'package:flutter/material.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/model/occupation/occupation_period.dart';

/// État de base du calendrier d'occupation
sealed class OccupationCalendarState {
  final List<OccupationPeriod> periods;
  final Map<int, Color> colors;
  final DateTime focusedMonth;
  final OccupationCalendarMode mode;

  /// Contexte source pour permettre le rechargement automatique lors de la navigation
  final int? sourceAppartementId;       // mode apartment
  final List<int>? sourceAppartementIds; // mode residence

  OccupationCalendarState({
    this.periods = const [],
    this.colors = const {},
    DateTime? focusedMonth,
    this.mode = OccupationCalendarMode.apartment,
    this.sourceAppartementId,
    this.sourceAppartementIds,
  }) : focusedMonth = focusedMonth ?? DateTime.now();

  /// Vérifie si une date est occupée
  bool isOccupied(DateTime date) {
    return periods.any((period) => period.contains(date));
  }

  /// Retourne toutes les périodes qui occupent une date donnée
  List<OccupationPeriod> getPeriodsForDate(DateTime date) {
    return periods.where((period) => period.contains(date)).toList();
  }

  /// Retourne les appartements distincts présents dans les périodes
  Set<int> get distinctApartmentIds {
    return periods.map((p) => p.appartementId).toSet();
  }
}

/// État initial
class OccupationInitial extends OccupationCalendarState {
  OccupationInitial() : super();
}

/// Chargement en cours
class OccupationLoading extends OccupationCalendarState {
  OccupationLoading({
    super.periods,
    super.colors,
    super.focusedMonth,
    super.mode,
    super.sourceAppartementId,
    super.sourceAppartementIds,
  });
}

/// Données chargées avec succès
class OccupationLoaded extends OccupationCalendarState {
  final List<DateTime> selectedDates; // Pour mode sélection (locataire)

  OccupationLoaded({
    required super.periods,
    required super.colors,
    required super.focusedMonth,
    required super.mode,
    super.sourceAppartementId,
    super.sourceAppartementIds,
    this.selectedDates = const [],
  });

  /// Vérifie si une date est sélectionnée
  bool isSelected(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return selectedDates.any((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);
  }

  /// Crée une copie avec modifications
  OccupationLoaded copyWith({
    List<OccupationPeriod>? periods,
    Map<int, Color>? colors,
    DateTime? focusedMonth,
    OccupationCalendarMode? mode,
    int? sourceAppartementId,
    List<int>? sourceAppartementIds,
    List<DateTime>? selectedDates,
  }) {
    return OccupationLoaded(
      periods: periods ?? this.periods,
      colors: colors ?? this.colors,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      mode: mode ?? this.mode,
      sourceAppartementId: sourceAppartementId ?? this.sourceAppartementId,
      sourceAppartementIds: sourceAppartementIds ?? this.sourceAppartementIds,
      selectedDates: selectedDates ?? this.selectedDates,
    );
  }
}

/// Erreur lors du chargement
class OccupationError extends OccupationCalendarState {
  final String message;

  OccupationError({
    required this.message,
    super.periods,
    super.colors,
    super.focusedMonth,
    super.mode,
    super.sourceAppartementId,
    super.sourceAppartementIds,
  });
}
