/// Type de réservation
///
/// - [plateforme] : Réservation effectuée via la plateforme Asfar (avec frais)
/// - [manuelle] : Réservation ajoutée manuellement par le propriétaire (sans frais)
enum ReservationType {
  plateforme('PLATEFORME'),
  manuelle('MANUELLE'),
  demarcheur('DEMARCHEUR');

  const ReservationType(this.value);
  final String value;

  static ReservationType fromString(String value) {
    return ReservationType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ReservationType.plateforme,
    );
  }

  /// Libellé pour l'affichage
  String get label {
    switch (this) {
      case ReservationType.plateforme:
        return 'Plateforme';
      case ReservationType.manuelle:
        return 'Manuelle';
      case ReservationType.demarcheur:
        return 'Démarcheur';
    }
  }

  /// Icône associée
  String get icon {
    switch (this) {
      case ReservationType.plateforme:
        return '🌐';
      case ReservationType.manuelle:
        return '📝';
      case ReservationType.demarcheur:
        return '🤝';
    }
  }
}
