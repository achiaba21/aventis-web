import 'package:asfar/model/ui_only/commission_transaction.dart';

/// Données mock du wallet démarcheur — alignées sur l'historique du proto
/// (`demarcheur.jsx::DemarcheurWallet`, lignes 511-517).
class SampleCommissions {
  SampleCommissions._();

  static final List<CommissionTransaction> all = [
    CommissionTransaction(
      id: 'TX-1108',
      label: 'Versement OM',
      subtitle: 'Sem. 45',
      date: DateTime(2025, 11, 8),
      amount: 75000,
      type: TransactionType.withdrawalOut,
    ),
    CommissionTransaction(
      id: 'TX-1107',
      label: 'Yacouba D. — Loft Plateau',
      subtitle: 'Séjour terminé',
      date: DateTime(2025, 11, 7),
      amount: 31500,
      type: TransactionType.commissionIn,
    ),
    CommissionTransaction(
      id: 'TX-1105',
      label: 'Akua N. — Vue lagune',
      subtitle: 'Paiement client confirmé',
      date: DateTime(2025, 11, 5),
      amount: 13600,
      type: TransactionType.commissionIn,
    ),
    CommissionTransaction(
      id: 'TX-1101',
      label: 'Versement OM',
      subtitle: 'Sem. 44',
      date: DateTime(2025, 11, 1),
      amount: 53000,
      type: TransactionType.withdrawalOut,
    ),
    CommissionTransaction(
      id: 'TX-1030',
      label: 'Mariam T. — Studio Cocody',
      subtitle: 'Paiement client confirmé',
      date: DateTime(2025, 10, 30),
      amount: 9600,
      type: TransactionType.commissionIn,
    ),
    CommissionTransaction(
      id: 'TX-1024',
      label: 'Diallo S. — Penthouse Almadies',
      subtitle: 'Séjour terminé',
      date: DateTime(2025, 10, 24),
      amount: 84000,
      type: TransactionType.commissionIn,
    ),
  ];
}
