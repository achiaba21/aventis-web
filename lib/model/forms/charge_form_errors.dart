/// Erreurs de validation du formulaire de charge, par champ.
///
/// [isValid] est vrai quand aucun champ n'est en erreur. [montantValue] porte
/// le montant parsé (FCFA entier) quand il est valide, pour éviter au call site
/// de re-parser.
class ChargeFormErrors {
  final String? appartement;
  final String? montant;
  final String? date;

  /// Montant parsé si valide, sinon `null`.
  final double? montantValue;

  const ChargeFormErrors({
    this.appartement,
    this.montant,
    this.date,
    this.montantValue,
  });

  bool get isValid =>
      appartement == null && montant == null && date == null;
}
