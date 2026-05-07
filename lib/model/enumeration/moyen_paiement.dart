enum MoyenPaiement {
  OM('OM'),
  MOOV_MONNEY('MOOV_MONNEY'),
  MOMO('MOMO'),
  WAVE('WAVE');

  const MoyenPaiement(this.value);
  final String value;

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
