/// Une barre du `Sparkbar` 6 mois — Dashboard propriétaire.
///
/// Reproduit le mock `months` du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 10-14). [highlight] vaut `true` pour le mois courant (dernière barre
/// en accent or avec étiquette flottante).
class MonthlyRevenue {
  final String monthShort;
  final int amount;
  final bool highlight;

  const MonthlyRevenue({
    required this.monthShort,
    required this.amount,
    this.highlight = false,
  });
}
