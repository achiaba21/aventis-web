/// KPI affiché dans la grid 2×2 du Dashboard propriétaire.
///
/// Reproduit le modèle des `Stat` du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 80-86). Le delta est signé : positif = success, négatif = danger.
class ProprioKpi {
  final String label;
  final String value;
  final int deltaPercent;

  const ProprioKpi({
    required this.label,
    required this.value,
    required this.deltaPercent,
  });
}
