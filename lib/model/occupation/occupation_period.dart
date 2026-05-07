import 'package:flutter/material.dart';

/// Représente une période occupée (réservation confirmée) pour un appartement
///
/// Cette classe modélise une plage de dates pendant laquelle un appartement
/// est occupé par une réservation confirmée.
class OccupationPeriod {
  /// ID de l'appartement concerné
  final int appartementId;

  /// ID de la réservation (optionnel)
  final int? reservationId;

  /// Date de début de l'occupation
  final DateTime startDate;

  /// Date de fin de l'occupation
  final DateTime endDate;

  /// Nom de l'appartement (optionnel, pour affichage)
  final String? appartementName;

  const OccupationPeriod({
    required this.appartementId,
    this.reservationId,
    required this.startDate,
    required this.endDate,
    this.appartementName,
  });

  /// Crée une instance depuis JSON
  factory OccupationPeriod.fromJson(Map<String, dynamic> json) {
    return OccupationPeriod(
      appartementId: json['appartementId'] ?? json['apartmentId'] ?? 0,
      reservationId: json['reservationId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      appartementName: json['appartementName'] ?? json['apartmentName'],
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'appartementId': appartementId,
      'reservationId': reservationId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'appartementName': appartementName,
    };
  }

  /// Vérifie si une date donnée est contenue dans cette période
  ///
  /// Retourne true si la date est >= startDate ET <= endDate (inclusif)
  bool contains(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return (dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAfter(startOnly)) &&
        (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  /// Retourne la plage comme DateTimeRange
  DateTimeRange get plage => DateTimeRange(
        start: startDate.copyWith(hour: 0, minute: 0, second: 0),
        end: endDate.copyWith(hour: 23, minute: 59, second: 59),
      );

  @override
  String toString() {
    return 'OccupationPeriod(appartementId: $appartementId, '
        'reservationId: $reservationId, '
        'startDate: $startDate, endDate: $endDate, '
        'appartementName: $appartementName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OccupationPeriod &&
        other.appartementId == appartementId &&
        other.reservationId == reservationId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return appartementId.hashCode ^
        reservationId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode;
  }
}
