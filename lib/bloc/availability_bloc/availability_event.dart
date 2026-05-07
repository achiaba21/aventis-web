import 'package:flutter/material.dart';

/// Événements pour le BLoC de disponibilité des appartements
/// Gère le blocage/déblocage de dates par le propriétaire
abstract class AvailabilityEvent {}

/// Charge les disponibilités d'un appartement
class LoadAvailability extends AvailabilityEvent {
  final int appartementId;
  LoadAvailability(this.appartementId);
}

/// Rafraîchit les disponibilités depuis l'API
class RefreshAvailability extends AvailabilityEvent {
  final int appartementId;
  RefreshAvailability(this.appartementId);
}

/// Bloque une plage de dates pour un appartement
class BlockDates extends AvailabilityEvent {
  final int appartementId;
  final DateTimeRange dateRange;
  BlockDates(this.appartementId, this.dateRange);
}

/// Débloque une plage de dates pour un appartement
class UnblockDates extends AvailabilityEvent {
  final int appartementId;
  final int blockId;
  UnblockDates(this.appartementId, this.blockId);
}

/// Sélectionne une date dans le calendrier (mode édition)
class SelectDate extends AvailabilityEvent {
  final DateTime date;
  SelectDate(this.date);
}

/// Désélectionne une date
class DeselectDate extends AvailabilityEvent {
  final DateTime date;
  DeselectDate(this.date);
}

/// Efface toute la sélection en cours
class ClearSelection extends AvailabilityEvent {}

/// Réinitialise l'état du BLoC
class ResetAvailabilityState extends AvailabilityEvent {}
