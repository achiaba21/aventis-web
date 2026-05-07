/// Représente une période bloquée par le propriétaire
class BlockedPeriod {
  final int id;
  final DateTime startDate;
  final DateTime endDate;

  BlockedPeriod({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  factory BlockedPeriod.fromJson(Map<String, dynamic> json) {
    return BlockedPeriod(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  /// Vérifie si une date est dans cette période
  bool contains(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
           (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }
}

/// Représente une période réservée par un locataire
class ReservedPeriod {
  final int reservationId;
  final DateTime startDate;
  final DateTime endDate;
  final String? locataireName;

  ReservedPeriod({
    required this.reservationId,
    required this.startDate,
    required this.endDate,
    this.locataireName,
  });

  factory ReservedPeriod.fromJson(Map<String, dynamic> json) {
    return ReservedPeriod(
      reservationId: json['reservationId'] ?? json['id'],
      startDate: DateTime.parse(json['startDate'] ?? json['dateDebut']),
      endDate: DateTime.parse(json['endDate'] ?? json['dateFin']),
      locataireName: json['locataireName'] ?? json['locataire']?['nom'],
    );
  }

  /// Vérifie si une date est dans cette période
  bool contains(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);
    return (dateOnly.isAtSameMomentAs(startOnly) || dateOnly.isAfter(startOnly)) &&
           (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }
}

/// État de base pour la disponibilité
abstract class AvailabilityState {
  /// Dates bloquées manuellement par le propriétaire
  final List<BlockedPeriod> blockedPeriods;

  /// Dates réservées par des locataires
  final List<ReservedPeriod> reservedPeriods;

  /// Dates sélectionnées en cours (avant confirmation)
  final List<DateTime> selectedDates;

  /// ID de l'appartement concerné
  final int? appartementId;

  AvailabilityState({
    this.blockedPeriods = const [],
    this.reservedPeriods = const [],
    this.selectedDates = const [],
    this.appartementId,
  });

  /// Vérifie si une date est bloquée
  bool isBlocked(DateTime date) {
    return blockedPeriods.any((period) => period.contains(date));
  }

  /// Vérifie si une date est réservée
  bool isReserved(DateTime date) {
    return reservedPeriods.any((period) => period.contains(date));
  }

  /// Vérifie si une date est sélectionnée (en cours d'édition)
  bool isSelected(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return selectedDates.any((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);
  }

  /// Vérifie si une date est disponible
  bool isAvailable(DateTime date) {
    return !isBlocked(date) && !isReserved(date);
  }

  /// Retourne le statut d'une date
  DateStatus getDateStatus(DateTime date) {
    if (isReserved(date)) return DateStatus.reserved;
    if (isBlocked(date)) return DateStatus.blocked;
    if (isSelected(date)) return DateStatus.selected;
    return DateStatus.available;
  }
}

/// Statut d'une date dans le calendrier
enum DateStatus {
  available,  // Disponible (fond par défaut)
  reserved,   // Réservé par un locataire (orange)
  blocked,    // Bloqué par le propriétaire (gris)
  selected,   // Sélectionné pour blocage (bordure orange)
}

/// État initial
class AvailabilityInitial extends AvailabilityState {
  AvailabilityInitial() : super();
}

/// Chargement en cours
class AvailabilityLoading extends AvailabilityState {
  AvailabilityLoading({
    super.blockedPeriods,
    super.reservedPeriods,
    super.selectedDates,
    super.appartementId,
  });
}

/// Données chargées avec succès
class AvailabilityLoaded extends AvailabilityState {
  AvailabilityLoaded({
    required int appartementId,
    required List<BlockedPeriod> blockedPeriods,
    required List<ReservedPeriod> reservedPeriods,
    List<DateTime> selectedDates = const [],
  }) : super(
          appartementId: appartementId,
          blockedPeriods: blockedPeriods,
          reservedPeriods: reservedPeriods,
          selectedDates: selectedDates,
        );

  /// Crée une copie avec les modifications spécifiées
  AvailabilityLoaded copyWith({
    int? appartementId,
    List<BlockedPeriod>? blockedPeriods,
    List<ReservedPeriod>? reservedPeriods,
    List<DateTime>? selectedDates,
  }) {
    return AvailabilityLoaded(
      appartementId: appartementId ?? this.appartementId!,
      blockedPeriods: blockedPeriods ?? this.blockedPeriods,
      reservedPeriods: reservedPeriods ?? this.reservedPeriods,
      selectedDates: selectedDates ?? this.selectedDates,
    );
  }
}

/// Opération réussie (blocage/déblocage)
class AvailabilityOperationSuccess extends AvailabilityState {
  final String message;

  AvailabilityOperationSuccess({
    required this.message,
    required int appartementId,
    required List<BlockedPeriod> blockedPeriods,
    required List<ReservedPeriod> reservedPeriods,
  }) : super(
          appartementId: appartementId,
          blockedPeriods: blockedPeriods,
          reservedPeriods: reservedPeriods,
        );
}

/// Erreur
class AvailabilityError extends AvailabilityState {
  final String message;

  AvailabilityError({
    required this.message,
    super.blockedPeriods,
    super.reservedPeriods,
    super.selectedDates,
    super.appartementId,
  });
}
