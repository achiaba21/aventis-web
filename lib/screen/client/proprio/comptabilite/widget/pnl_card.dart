import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

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
          _categoryHeader(revenueHeader),
          for (final d in revenueDetails) _detailLine(d),
          const SizedBox(height: 12),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 12),
          _categoryHeader(chargeHeader),
          for (final d in chargeDetails) _detailLine(d),
          const SizedBox(height: 12),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 12),
          _netIncomeRow(),
          const SizedBox(height: 4),
          _netMarginRow(),
        ],
      ),
    );
  }

  Widget _categoryHeader(PnLEntry entry) {
    final color = entry.isRevenue ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            entry.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            FcfaFormatter.compact(entry.amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            )),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(PnLEntry entry) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(fontSize: 13, color: AppColors.text2),
            ),
          ),
          Text(
            FcfaFormatter.compact(entry.amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
            )),
          ),
        ],
      ),
    );
  }

  Widget _netIncomeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bénéfice net',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        Text(
          FcfaFormatter.compact(netIncome.amount),
          style: AppTextStyles.mono(const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          )),
        ),
      ],
    );
  }

  Widget _netMarginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Marge nette',
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
        Text(
          '${netMargin.amount}%',
          style: AppTextStyles.mono(const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          )),
        ),
      ],
    );
  }
}
