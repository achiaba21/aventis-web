/// Moyens de paiement supportés par la plateforme Asfar.
///
/// L'enum sert à la fois pour la traçabilité (réservations Asfar payées) et
/// pour le tracking manuel proprio (réservation hors plateforme).
///
/// Côté serveur, ces valeurs sont sérialisées via `value` (chaîne uppercase).
enum MoyenPaiement {
  OM('OM'),
  MOOV_MONNEY('MOOV_MONNEY'),
  MOMO('MOMO'),
  WAVE('WAVE'),
  ESPECES('ESPECES'),
  VIREMENT('VIREMENT');

  const MoyenPaiement(this.value);
  final String value;

  /// Libellé utilisateur (français).
  String get label {
    switch (this) {
      case MoyenPaiement.OM:
        return 'Orange Money';
      case MoyenPaiement.MOOV_MONNEY:
        return 'Moov Money';
      case MoyenPaiement.MOMO:
        return 'MTN MoMo';
      case MoyenPaiement.WAVE:
        return 'Wave';
      case MoyenPaiement.ESPECES:
        return 'Espèces';
      case MoyenPaiement.VIREMENT:
        return 'Virement';
    }
  }

  /// Liste des moyens proposés au proprio pour une réservation manuelle.
  /// Aligné sur le proto wizard step 2 : 4 chips (Espèces, Wave, Orange Money, Virement).
  static const List<MoyenPaiement> manualReservationOptions = [
    MoyenPaiement.ESPECES,
    MoyenPaiement.WAVE,
    MoyenPaiement.OM,
    MoyenPaiement.VIREMENT,
  ];

  static MoyenPaiement? fromString(String? value) {
    if (value == null) return null;
    try {
      return MoyenPaiement.values.firstWhere(
        (e) => e.value == value.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String toJson() => value;
}
