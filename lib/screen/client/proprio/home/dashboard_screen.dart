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
import 'package:asfar/model/ui_only/pending_request.dart';
import 'package:asfar/screen/client/proprio/appartements/listing_edit_screen.dart';
import 'package:asfar/screen/client/proprio/appartements/listings_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/finances_screen.dart';
import 'package:asfar/screen/client/proprio/home/widget/cashflow_split_card.dart';
import 'package:asfar/screen/client/proprio/reservations/proprio_reservations_screen.dart';
import 'package:asfar/screen/client/proprio/home/widget/kpi_tile.dart';
import 'package:asfar/screen/client/proprio/home/widget/pending_request_row.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_listing_row.dart';
import 'package:asfar/screen/client/proprio/home/widget/revenue_hero_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/cashflow_aggregator.dart';
import 'package:asfar/util/calc/kpi_aggregator.dart';
import 'package:asfar/util/calc/monthly_revenue_calculator.dart';
import 'package:asfar/util/calc/property_perf_aggregator.dart';
import 'package:asfar/util/mapping/reservation_to_pending_request.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Dashboard du Propriétaire — onglet Accueil du `ProprioShell`.
///
/// V8.5 Lot 8b : branché sur `AppartementBloc` + `ReservationBloc` +
/// `ChargeBloc` via les Calculators (Lot 8a). Toutes les données mocks
/// (`SampleProprioStats`, `SamplePropertyPerf`) sont remplacées par les
/// agrégations live des BLoCs.
class ProprioDashboard extends StatefulWidget {
  final String firstName;

  const ProprioDashboard({super.key, this.firstName = 'Aminata'});

  @override
  State<ProprioDashboard> createState() => _ProprioDashboardState();
}

class _ProprioDashboardState extends State<ProprioDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Charge en parallèle les 3 sources de données nécessaires au Dashboard.
      // Pattern cache-first côté Repositories → render instantané.
      context.read<ReservationBloc>().add(LoadProprietaireReservations());
      context.read<AppartementBloc>().add(LoadProprietaireAppartements());
      context.read<ChargeBloc>().add(LoadCharges());
    });
  }

  void _stub(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Bienvenue, $firstName',
        eyebrow: 'TABLEAU DE BORD',
        leading: IconBoutton(
          icon: Icons.grid_view_outlined,
          onPressed: () =>
              _stub(context, 'Vue alternative disponible prochainement'),
        ),
        trailing: IconBoutton(
          icon: Icons.notifications_none,
          onPressed: () =>
              _stub(context, 'Notifications disponibles prochainement (V8)'),
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
                        context, appartements, reservations, charges);
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
    BuildContext context,
    List<Appartement> appartements,
    List<Reservation> reservations,
    List<Charge> charges,
  ) {
    final monthlyAmount =
        MonthlyRevenueCalculator.currentMonth(reservations);
    final previousAmount =
        MonthlyRevenueCalculator.previousMonth(reservations);
    final deltaPercent = MonthlyRevenueCalculator.deltaPercent(reservations);
    final last6 = MonthlyRevenueCalculator.last6Months(reservations);

    final kpis = KpiAggregator.fromData(
      appartements: appartements,
      reservations: reservations,
    );

    final cashflow = CashflowAggregator.currentMonth(
      reservations: reservations,
      charges: charges,
    );

    final perfs = PropertyPerfAggregator.compute(
      appartements: appartements,
      reservations: reservations,
    );

    final pending = ReservationToPendingRequestMapper.mapPending(reservations);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevenueHeroCard(
            amount: monthlyAmount,
            deltaPercent: deltaPercent,
            previousAmount: previousAmount,
            last6Months: last6,
          ),
          const SizedBox(height: 16),
          _kpiGrid(kpis),
          const SizedBox(height: 22),
          _cashflowSection(context, cashflow),
          const SizedBox(height: 22),
          _listingsSection(context, perfs),
          const SizedBox(height: 22),
          _buildPendingSection(context, pending),
        ],
      ),
    );
  }

  Widget _kpiGrid(List kpis) {
    if (kpis.length < 4) {
      return EmptyState.inline(
        icon: Icons.bar_chart_outlined,
        title: 'Stats indisponibles',
        body: 'Les statistiques se chargent…',
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: KpiTile(kpi: kpis[0])),
            const SizedBox(width: 10),
            Expanded(child: KpiTile(kpi: kpis[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: KpiTile(kpi: kpis[2])),
            const SizedBox(width: 10),
            Expanded(child: KpiTile(kpi: kpis[3])),
          ],
        ),
      ],
    );
  }

  Widget _cashflowSection(BuildContext context, List cashflow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Flux financier',
          actionLabel: 'Détails →',
          onActionTap: () =>
              pushScreen(context, const ProprioFinancesScreen()),
        ),
        const SizedBox(height: 4),
        if (cashflow.isEmpty)
          EmptyState.inline(
            icon: Icons.account_balance_outlined,
            title: 'Pas encore de flux',
            body: 'Les revenus du mois apparaîtront ici.',
          )
        else
          CashflowSplitCard(segments: List.from(cashflow)),
      ],
    );
  }

  Widget _listingsSection(BuildContext context, List perfs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Mes annonces',
          actionLabel: 'Tout voir',
          onActionTap: () => pushScreen(context, const ProprioListingsScreen()),
        ),
        const SizedBox(height: 4),
        if (perfs.isEmpty)
          EmptyState.inline(
            icon: Icons.home_work_outlined,
            title: 'Aucune annonce',
            body: 'Vos annonces apparaîtront ici.',
          )
        else
          for (var i = 0; i < perfs.length; i++) ...[
            ProprioListingRow(
              listing: perfs[i].listing,
              occupancyRate: perfs[i].occupancyRate,
              monthlyRevenue: perfs[i].monthlyRevenue,
              onTap: () => pushScreen(
                context,
                ProprioListingEditScreen(listing: perfs[i].listing),
              ),
            ),
            if (i != perfs.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildPendingSection(
      BuildContext context, List<PendingRequest> pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Demandes en attente',
          actionLabel: 'Voir tout',
          onActionTap: () =>
              pushScreen(context, const ProprioReservationsScreen()),
        ),
        const SizedBox(height: 4),
        if (pending.isEmpty)
          EmptyState.inline(
            icon: Icons.inbox_outlined,
            title: 'Aucune demande en attente',
            body: 'Les nouvelles demandes de réservation apparaîtront ici.',
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < pending.length; i++)
                  PendingRequestRow(
                    request: pending[i],
                    isLast: i == pending.length - 1,
                    onTap: () => _stub(context,
                        'Détail demande disponible prochainement (F5)'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Astuce : répondre vite augmente votre taux d\'acceptation.',
          style: AppTextStyles.small.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
