/// Type d'une transaction wallet démarcheur.
///
/// `commissionIn` = entrée d'argent (commission perçue après paiement client).
/// `withdrawalOut` = sortie d'argent (versement vers Orange Money).
enum TransactionType { commissionIn, withdrawalOut }

/// Modèle UI-only pour une transaction du wallet démarcheur.
///
/// Reproduit la structure du proto `demarcheur.jsx::DemarcheurWallet`
/// (mock historique 6 transactions, lignes 511-517). Sert uniquement à
/// typer les samples Vague 6 en attendant le branchement BLoC réel.
class CommissionTransaction {
  final String id;
  final String label;
  final String subtitle;
  final DateTime date;
  final int amount;
  final TransactionType type;

  const CommissionTransaction({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.type,
  });

  bool get isIncoming => type == TransactionType.commissionIn;
}
