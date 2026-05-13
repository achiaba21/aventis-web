/// Information minimale sur un appartement (nom safe).
///
/// Utilisé par `ChargeDataManager` pour pré-remplir `Charge.appartementNom`
/// en mode offline. Le champ résidence a été retiré (refacto BACKEND-FLAT,
/// confirmé 2026-05-13).
class AppartementInfo {
  final String? appartementNom;

  const AppartementInfo({this.appartementNom});

  /// Crée une instance vide (appartement non trouvé)
  const AppartementInfo.empty() : appartementNom = null;

  /// Indique si l'info est valide (appartement trouvé)
  bool get isValid => appartementNom != null;
}
