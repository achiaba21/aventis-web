import 'package:flutter/material.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/model/occupation/occupation_period.dart';

/// Events pour le BLoC du calendrier d'occupation
sealed class OccupationCalendarEvent {}

/// Charge les périodes d'occupation pour un appartement donné
class LoadOccupation extends OccupationCalendarEvent {
  final int appartementId;
  final int month;
  final int year;

  LoadOccupation({
    required this.appartementId,
    required this.month,
    required this.year,
  });
}

/// Charge les périodes d'occupation pour une résidence (multi-appartements)
class LoadOccupationForResidence extends OccupationCalendarEvent {
  final int residenceId;
  final List<int> appartementIds;
  final int month;
  final int year;

  LoadOccupationForResidence({
    required this.residenceId,
    required this.appartementIds,
    required this.month,
    required this.year,
  });
}

/// Navigue vers un autre mois (précédent ou suivant)
class NavigateMonth extends OccupationCalendarEvent {
  final int monthOffset; // -1 pour mois précédent, +1 pour suivant

  NavigateMonth(this.monthOffset);
}

/// Sélectionne une date (pour mode sélection locataire)
class SelectOccupationDate extends OccupationCalendarEvent {
  final DateTime date;

  SelectOccupationDate(this.date);
}

/// Désélectionne une date (pour mode sélection locataire)
class DeselectOccupationDate extends OccupationCalendarEvent {
  final DateTime date;

  DeselectOccupationDate(this.date);
}

/// Confirme la sélection de plage (pour mode sélection locataire)
class ConfirmSelection extends OccupationCalendarEvent {
  final DateTimeRange range;

  ConfirmSelection(this.range);
}

/// Annule la sélection (pour mode sélection locataire)
class CancelSelection extends OccupationCalendarEvent {}

/// Réinitialise l'état du BLoC
class ResetOccupationState extends OccupationCalendarEvent {}

/// Charge l'occupation depuis des données locales (sans appel API)
/// Utilisé pour les propriétaires qui ont déjà les réservations en mémoire
class LoadOccupationFromLocal extends OccupationCalendarEvent {
  final List<OccupationPeriod> periods;
  final OccupationCalendarMode mode;
  final int month;
  final int year;

  LoadOccupationFromLocal({
    required this.periods,
    required this.mode,
    required this.month,
    required this.year,
  });
}
