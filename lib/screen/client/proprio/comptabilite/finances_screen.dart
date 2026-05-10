import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/benefice_net_hero_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/period_switcher.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/projection_chart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/property_perf_row.dart';
import 'package:asfar/screen/client/proprio/sample/sample_pnl_entries.dart';
import 'package:asfar/screen/client/proprio/sample/sample_projection_points.dart';
import 'package:asfar/screen/client/proprio/sample/sample_property_perf.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Finances P&L — onglet Finances du `ProprioShell`.
///
/// Reproduit `ProprietaireFinances` du prototype : period switcher 4 options,
/// hero bénéfice net, compte de résultat (PnLCard), performance par bien,
/// projection 3 mois (ProjectionChart fl_chart), CTA exporter PDF/CSV.
class ProprioFinancesScreen extends StatefulWidget {
  const ProprioFinancesScreen({super.key});

  @override
  State<ProprioFinancesScreen> createState() => _ProprioFinancesScreenState();
}

class _ProprioFinancesScreenState extends State<ProprioFinancesScreen> {
  static const _periods = ['Semaine', 'Mois', 'Trimestre', 'Année'];

  String _period = 'Mois';

  void _stub(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfs = SamplePropertyPerf.all;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Finances',
        eyebrow: 'P&L · CHARGES · PROJECTIONS',
        leading: Navigator.canPop(context)
            ? IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              )
            : null,
        trailing: IconBoutton(
          icon: Icons.download_outlined,
          onPressed: () =>
              _stub('Export PDF/CSV disponible prochainement (F8)'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PeriodSwitcher(
                options: _periods,
                selected: _period,
                onSelect: (p) => setState(() => _period = p),
              ),
              const SizedBox(height: 18),
              const BeneficeNetHeroCard(
                amount: 1178000,
                deltaPercent: 24,
              ),
              const SizedBox(height: 22),
              const Text('Compte de résultat', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              const PnLCard(
                revenueHeader: SamplePnLEntries.revenueHeader,
                revenueDetails: SamplePnLEntries.revenueDetails,
                chargeHeader: SamplePnLEntries.chargeHeader,
                chargeDetails: SamplePnLEntries.chargeDetails,
                netIncome: SamplePnLEntries.netIncome,
                netMargin: SamplePnLEntries.netMargin,
              ),
              const SizedBox(height: 22),
              const Text('Performance par bien', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgElev1,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < perfs.length; i++)
                      PropertyPerfRow(
                        perf: perfs[i],
                        isLast: i == perfs.length - 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Projection 3 mois', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgElev1,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: ProjectionChart(
                  points: SampleProjectionPoints.all,
                  q1Estimation: SampleProjectionPoints.q1Estimation,
                ),
              ),
              const SizedBox(height: 22),
              OutlinedCustomButton(
                text: 'Exporter en PDF / CSV',
                onPressed: () =>
                    _stub('Export PDF/CSV disponible prochainement (F8)'),
                size: ButtonSize.lg,
                block: true,
                leadingIcon: Icons.download_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
