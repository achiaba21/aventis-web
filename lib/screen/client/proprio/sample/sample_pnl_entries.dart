import 'package:asfar/model/ui_only/pnl_entry.dart';

/// Données mock du compte de résultat (`PnLCard`) — alignées sur
/// `proprietaire.jsx::ProprietaireFinances` (lignes 222-271).
class SamplePnLEntries {
  SamplePnLEntries._();

  /// En-tête « + Revenus » — total 1.9M.
  static const PnLEntry revenueHeader = PnLEntry(
    label: '+ Revenus',
    amount: 1900000,
    kind: PnLKind.categoryHeader,
    isRevenue: true,
  );

  /// Lignes détaillées sous « Revenus ».
  static const List<PnLEntry> revenueDetails = [
    PnLEntry(
      label: 'Locations brutes (42 nuits)',
      amount: 1900000,
      kind: PnLKind.categoryDetail,
      isRevenue: true,
    ),
    PnLEntry(
      label: 'Frais ménage facturés',
      amount: 84000,
      kind: PnLKind.categoryDetail,
      isRevenue: true,
    ),
  ];

  /// En-tête « − Charges » — total 722k.
  static const PnLEntry chargeHeader = PnLEntry(
    label: '− Charges',
    amount: 722000,
    kind: PnLKind.categoryHeader,
    isRevenue: false,
  );

  /// Lignes détaillées sous « Charges ».
  static const List<PnLEntry> chargeDetails = [
    PnLEntry(
      label: 'Frais plateforme Asfar (6%)',
      amount: 114000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
    PnLEntry(
      label: 'Commissions démarcheurs',
      amount: 228000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
    PnLEntry(
      label: 'Ménage & blanchisserie',
      amount: 168000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
    PnLEntry(
      label: 'Eau & électricité',
      amount: 92000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
    PnLEntry(
      label: 'Maintenance & réparations',
      amount: 75000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
    PnLEntry(
      label: 'Internet & TV',
      amount: 45000,
      kind: PnLKind.categoryDetail,
      isRevenue: false,
    ),
  ];

  /// Bénéfice net (accent or 18px bold).
  static const PnLEntry netIncome = PnLEntry(
    label: 'Bénéfice net',
    amount: 1178000,
    kind: PnLKind.netIncome,
  );

  /// Marge nette (% — small success).
  static const PnLEntry netMargin = PnLEntry(
    label: 'Marge nette',
    amount: 62, // pourcentage entier
    kind: PnLKind.netMargin,
  );
}
