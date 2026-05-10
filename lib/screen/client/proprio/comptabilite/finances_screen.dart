import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/benefice_net_hero_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/period_switcher.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/projection_chart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/property_perf_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/monthly_revenue_calculator.dart';
import 'package:asfar/util/calc/pnl_aggregator.dart';
import 'package:asfar/util/calc/projection_calculator.dart';
import 'package:asfar/util/calc/property_perf_aggregator.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Finances P&L — onglet Finances du `ProprioShell`.
///
/// V8.5 Lot 8c : branché sur les Calculators (Lot 8a) + `PnLAggregator`
/// (Lot 8c) sur `AppartementBloc` + `ReservationBloc` + `ChargeBloc`.
/// Tous les mocks (`SamplePnLEntries`, `SamplePropertyPerf`,
/// `SampleProjectionPoints`) sont remplacés par des agrégations live.
class ProprioFinancesScreen extends StatefulWidget {
  const ProprioFinancesScreen({super.key});

  @override
  State<ProprioFinancesScreen> createState() => _ProprioFinancesScreenState();
}

class _ProprioFinancesScreenState extends State<ProprioFinancesScreen> {
  static const _periods = ['Semaine', 'Mois', 'Trimestre', 'Année'];

  String _period = 'Mois';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReservationBloc>().add(LoadProprietaireReservations());
      context.read<AppartementBloc>().add(LoadProprietaireAppartements());
      context.read<ChargeBloc>().add(LoadCharges());
    });
  }

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
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, appState) {
            return BlocBuilder<ReservationBloc, ReservationState>(
              builder: (context, resState) {
                return BlocBuilder<ChargeBloc, ChargeState>(
                  builder: (context, chargeState) {
                    final appartements = appState.appartements;
                    final reservations = resState.reservations;
                    final charges = chargeState is ChargeLoaded
                        ? chargeState.charges
                        : <Charge>[];
                    return _buildContent(
                      context,
                      appartements: appartements,
                      reservations: reservations,
                      charges: charges,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<Appartement> appartements,
    required List<Reservation> reservations,
    required List<Charge> charges,
  }) {
    final pnl = PnLAggregator.currentMonth(
      reservations: reservations,
      charges: charges,
    );
    final beneficeAmount = pnl.netIncome.amount;
    final deltaPercent =
        MonthlyRevenueCalculator.deltaPercent(reservations).round();
    final perfs = PropertyPerfAggregator.compute(
      appartements: appartements,
      reservations: reservations,
    );
    final projection = ProjectionCalculator.sevenMonths(reservations);
    final q1 = ProjectionCalculator.q1Estimation(reservations);

    return SingleChildScrollView(
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
          BeneficeNetHeroCard(
            amount: beneficeAmount,
            deltaPercent: deltaPercent,
          ),
          const SizedBox(height: 22),
          const Text('Compte de résultat', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          if (pnl.isEmpty)
            EmptyState.inline(
              icon: Icons.receipt_long_outlined,
              title: 'Aucun mouvement ce mois-ci',
              body:
                  'Le compte de résultat apparaîtra dès la première réservation.',
            )
          else
            PnLCard(
              revenueHeader: pnl.revenueHeader,
              revenueDetails: pnl.revenueDetails,
              chargeHeader: pnl.chargeHeader,
              chargeDetails: pnl.chargeDetails,
              netIncome: pnl.netIncome,
              netMargin: pnl.netMargin,
            ),
          const SizedBox(height: 22),
          const Text('Performance par bien', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          _perfsSection(perfs),
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
              points: projection,
              q1Estimation: q1,
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
    );
  }

  Widget _perfsSection(List<PropertyPerf> perfs) {
    if (perfs.isEmpty) {
      return EmptyState.inline(
        icon: Icons.home_work_outlined,
        title: 'Aucun bien à analyser',
        body: 'Vos performances par bien apparaîtront ici.',
      );
    }
    return Container(
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
    );
  }
}
