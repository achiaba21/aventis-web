import 'package:asfar/model/compte/transaction.dart' as compte;
import 'package:asfar/model/ui_only/commission_transaction.dart';

/// Mapper `Transaction` (modèle métier `lib/model/compte/transaction.dart`)
/// vers `CommissionTransaction` (modèle UI-only) consommé par
/// `WalletTransactionRow` du `DemarcheurWalletScreen`.
///
/// Règles :
/// - `type CREDIT` → `commissionIn` (entrée d'argent — commission perçue).
/// - `type DEBIT`  → `withdrawalOut` (sortie d'argent — retrait OM).
/// - `description` est utilisée comme `label`. `subtitle` est dérivé de
///   `statut` (« Paiement client confirmé » / « En attente » / « Annulée »
///   / « Versement OM »).
/// - `id` est préfixé `TX-` pour cohérence avec les samples V6.
class TransactionToCommissionMapper {
  TransactionToCommissionMapper._();

  static List<CommissionTransaction> mapMany(
    List<compte.Transaction> transactions,
  ) {
    return transactions.map(mapOne).toList();
  }

  static CommissionTransaction mapOne(compte.Transaction t) {
    final amount = (t.montant ?? 0).abs().round();
    final type = t.isCredit
        ? TransactionType.commissionIn
        : TransactionType.withdrawalOut;
    final label =
        (t.description?.isNotEmpty ?? false) ? t.description! : 'Mouvement';
    return CommissionTransaction(
      id: t.id != null ? 'TX-${t.id}' : 'TX-?',
      label: label,
      subtitle: _subtitleFor(t),
      date: t.dateTransaction ?? DateTime.now(),
      amount: amount,
      type: type,
    );
  }

  static String _subtitleFor(compte.Transaction t) {
    if (t.isDebit) {
      return t.isEnAttente ? 'Retrait en attente' : 'Versement OM';
    }
    if (t.isEnAttente) return 'En attente';
    if (t.statut == 'ANNULE') return 'Annulée';
    return 'Paiement confirmé';
  }
}
