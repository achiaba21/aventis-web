import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_category_header.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_detail_line.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_net_income_row.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_net_margin_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Compte de résultat — `ProprioFinancesScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 222-271). Structure :
/// - Header « + Revenus » success + total mono
/// - Lignes Revenus indentées (text-2)
/// - Divider
/// - Header « − Charges » danger + total mono
/// - Lignes Charges indentées
/// - Divider
/// - Footer « Bénéfice net » + montant accent or 18px
/// - Footer « Marge nette » + valeur % small success
class PnLCard extends StatelessWidget {
  final PnLEntry revenueHeader;
  final List<PnLEntry> revenueDetails;
  final PnLEntry chargeHeader;
  final List<PnLEntry> chargeDetails;
  final PnLEntry netIncome;
  final PnLEntry netMargin;

  const PnLCard({
    super.key,
    required this.revenueHeader,
    required this.revenueDetails,
    required this.chargeHeader,
    required this.chargeDetails,
    required this.netIncome,
    required this.netMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PnLCategoryHeader(entry: revenueHeader),
          for (final d in revenueDetails) PnLDetailLine(entry: d),
          const SizedBox(height: 12),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 12),
          PnLCategoryHeader(entry: chargeHeader),
          for (final d in chargeDetails) PnLDetailLine(entry: d),
          const SizedBox(height: 12),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 12),
          PnLNetIncomeRow(netIncome: netIncome),
          const SizedBox(height: 4),
          PnLNetMarginRow(netMargin: netMargin),
        ],
      ),
    );
  }
}
