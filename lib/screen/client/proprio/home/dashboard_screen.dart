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
import 'package:asfar/screen/client/proprio/appartements/listing_edit_screen.dart';
import 'package:asfar/screen/client/proprio/appartements/listings_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/finances_screen.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_cashflow_section.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_kpi_grid.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_listings_section.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_pending_section.dart';
import 'package:asfar/screen/client/proprio/home/widget/revenue_hero_card.dart';
import 'package:asfar/screen/client/proprio/reservations/proprio_reservations_screen.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/cashflow_aggregator.dart';
import 'package:asfar/util/calc/kpi_aggregator.dart';
import 'package:asfar/util/calc/property_perf_aggregator.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Dashboard du Propriétaire — onglet Accueil du `ProprioShell`.
///
/// V8.5 Lot 8b : branché sur `AppartementBloc` + `ReservationBloc` +
/// `ChargeBloc` via les Calculators (Lot 8a). Toutes les données mocks
/// sont remplacées par les agrégations live des BLoCs.
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

  void _toast(String message) {
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
          onPressed: () => _toast('Vue alternative disponible prochainement'),
        ),
        trailing: IconBoutton(
          icon: Icons.notifications_none,
          onPressed: () => pushScreen(context, const NotificationsScreen()),
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

                    final reservationsLoading =
                        resState is ReservationLoading &&
                            reservations.isEmpty;
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
                    final pending = reservations
                        .where((r) => r.statut == ReservationStatus.enAttente)
                        .toList(growable: false);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RevenueHeroCard(
                            reservations: reservations,
                            isLoading: reservationsLoading,
                          ),
                          const SizedBox(height: 16),
                          ProprioKpiGrid(kpis: kpis),
                          const SizedBox(height: 22),
                          ProprioCashflowSection(
                            segments: cashflow,
                            onSeeDetails: () => pushScreen(
                                context, const ProprioFinancesScreen()),
                          ),
                          const SizedBox(height: 22),
                          ProprioListingsSection(
                            perfs: perfs,
                            onSeeAll: () => pushScreen(
                                context, const ProprioListingsScreen()),
                            onListingTap: (appartement) => pushScreen(
                              context,
                              ProprioListingEditScreen(
                                  appartement: appartement),
                            ),
                          ),
                          const SizedBox(height: 22),
                          ProprioPendingSection(
                            pending: pending,
                            onSeeAll: () => pushScreen(
                                context, const ProprioReservationsScreen()),
                            onPendingTap: (_) => _toast(
                                'Détail demande disponible prochainement (F5)'),
                          ),
                        ],
                      ),
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
}
