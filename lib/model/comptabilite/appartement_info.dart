/// Information minimale sur un appartement et sa résidence
/// Utilisé pour éviter les Map<String, dynamic> non typés
class AppartementInfo {
  final int? residenceId;
  final String? residenceNom;
  final String? appartementNom;

  const AppartementInfo({
    this.residenceId,
    this.residenceNom,
    this.appartementNom,
  });

  /// Crée une instance vide (appartement non trouvé)
  const AppartementInfo.empty()
      : residenceId = null,
        residenceNom = null,
        appartementNom = null;

  /// Indique si l'info est valide (appartement trouvé)
  bool get isValid => residenceId != null;
}
