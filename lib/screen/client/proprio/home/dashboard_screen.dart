import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
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
import 'package:asfar/screen/client/proprio/sample/sample_property_perf.dart';
import 'package:asfar/screen/client/proprio/sample/sample_proprio_stats.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/mapping/reservation_to_pending_request.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Dashboard du Propriétaire — onglet Accueil du `ProprioShell`.
///
/// Reproduit `ProprietaireDashboard` du prototype : greeting eyebrow + h1 +
/// `RevenueHeroCard` + KPI grid 2×2 + `CashflowSplitCard` + section
/// « Mes annonces » (4 lignes) + section « Demandes en attente ».
///
/// V8.5 : trigger `LoadProprietaireReservations` au mount pour s'assurer
/// que la section « Demandes en attente » affiche bien les réservations
/// proprio (le state `ReservationBloc.reservations` peut être écrasé par
/// `LoadUserReservations` quand l'utilisateur bascule en mode Locataire,
/// le BLoC partage une seule liste pour les 2 vues).
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
      // Force LoadProprietaireReservations au mount — au cas où le state a été
      // écrasé par LoadUserReservations (vue Locataire). Le pattern cache-first
      // côté Repository garantit un rendu instantané.
      context.read<ReservationBloc>().add(LoadProprietaireReservations());
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
    final perfs = SamplePropertyPerf.all;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RevenueHeroCard(
                amount: SampleProprioStats.monthlyRevenue,
                deltaPercent: SampleProprioStats.monthlyDeltaPercent,
                previousAmount: SampleProprioStats.previousMonthRevenue,
                last6Months: SampleProprioStats.last6Months,
              ),
              const SizedBox(height: 16),
              _kpiGrid(),
              const SizedBox(height: 22),
              _cashflowSection(context),
              const SizedBox(height: 22),
              _listingsSection(context, perfs),
              const SizedBox(height: 22),
              _pendingSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiGrid() {
    final kpis = SampleProprioStats.kpis;
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

  Widget _cashflowSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Flux financier',
          actionLabel: 'Détails →',
          onActionTap: () => pushScreen(context, const ProprioFinancesScreen()),
        ),
        const SizedBox(height: 4),
        const CashflowSplitCard(segments: SampleProprioStats.cashflow),
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

  Widget _pendingSection(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        final pending = ReservationToPendingRequestMapper.mapPending(
          state.reservations,
        );
        return _buildPendingSection(context, pending);
      },
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
