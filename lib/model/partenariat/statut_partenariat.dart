enum StatutPartenariat {
  enAttente('EN_ATTENTE'),
  acceptee('ACCEPTEE'),
  refusee('REFUSEE');

  const StatutPartenariat(this.value);
  final String value;

  static StatutPartenariat fromString(String value) {
    return StatutPartenariat.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => StatutPartenariat.enAttente,
    );
  }
}
