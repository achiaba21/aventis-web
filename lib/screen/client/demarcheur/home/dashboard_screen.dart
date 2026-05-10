import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/demarcheur_listings_to_push_section.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/demarcheur_referrals_section.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/send_referral_cta_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pills_row.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/wallet_hero_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/new_referral_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referrals_screen.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/mapping/reservation_to_referral.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Dashboard du Démarcheur — Vague 6.
class DemarcheurDashboard extends StatefulWidget {
  final String firstName;

  const DemarcheurDashboard({super.key, this.firstName = 'Diallo'});

  @override
  State<DemarcheurDashboard> createState() => _DemarcheurDashboardState();
}

class _DemarcheurDashboardState extends State<DemarcheurDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DemarcheurBloc>().add(LoadDemarcheurReservations());
      context.read<DemarcheurBloc>().add(LoadDemarcheurAppartements());
      context.read<AppartementBloc>().add(LoadAppartements());
      context.read<CompteBloc>().add(LoadCompte());
    });
  }

  void _onOpenNew() => pushScreen(context, const NewReferralScreen());

  void _onOpenNewForAppart(Appartement appart) {
    pushScreen(context, NewReferralScreen(initialAppartement: appart));
  }

  void _onOpenReferralDetail(ReferralPreview r, Reservation? source) {
    pushScreen(context, ReferralDetailScreen(referral: r, source: source));
  }

  void _onOpenAllReferrals() =>
      pushScreen(context, const DemarcheurReferralsScreen());

  List<Reservation> _extractReservations(DemarcheurState state) {
    if (state is DemarcheurReservationsLoaded) return state.reservations;
    return const [];
  }

  /// Top 5 appartements à pousser, triés par note décroissante.
  List<Appartement> _topAppartsToPush(List<Appartement> apparts) {
    if (apparts.isEmpty) return const [];
    final sorted = List.of(apparts)
      ..sort((a, b) => (b.note).compareTo(a.note));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Bonjour, $firstName',
        eyebrow: 'TABLEAU DE BORD',
        trailing: IconBoutton(
          icon: Icons.notifications_none,
          onPressed: () => pushScreen(context, const NotificationsScreen()),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<DemarcheurBloc, DemarcheurState>(
          builder: (context, demarState) {
            final reservations = _extractReservations(demarState);
            return BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, appState) {
                return BlocBuilder<CompteBloc, CompteState>(
                  builder: (context, compteState) {
                    final solde = compteState is CompteLoaded
                        ? (compteState.compte.solde ?? 0).round()
                        : 0;

                    final monthCommission =
                        DemarcheurStatsCalculator.monthCommission(reservations);
                    final delta =
                        DemarcheurStatsCalculator.deltaPercent(reservations);
                    final totalCommission = solde > 0
                        ? solde
                        : DemarcheurStatsCalculator
                            .totalCommission(reservations);
                    final pendingCommission =
                        DemarcheurStatsCalculator.pendingCommission(
                            reservations);
                    final clientsCount =
                        DemarcheurStatsCalculator.clientsCount(reservations);
                    final pendingCount =
                        DemarcheurStatsCalculator.pendingCount(reservations);
                    final acceptedCount =
                        DemarcheurStatsCalculator.acceptedCount(reservations);
                    final acceptanceRate =
                        DemarcheurStatsCalculator.acceptanceRate(reservations);

                    final allReferrals =
                        ReservationToReferralMapper.mapMany(reservations);
                    final referrals = allReferrals.take(3).toList();
                    final sourceById = <String, Reservation>{
                      for (var i = 0;
                          i < allReferrals.length && i < reservations.length;
                          i++)
                        allReferrals[i].id: reservations[i],
                    };
                    final pushApparts =
                        _topAppartsToPush(appState.appartements);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WalletHeroCard(
                            monthCommission: monthCommission,
                            deltaPercent: delta,
                            totalCommission: totalCommission,
                            pendingCommission: pendingCommission,
                            clientsCount: clientsCount,
                          ),
                          const SizedBox(height: 16),
                          SendReferralCtaCard(onTap: _onOpenNew),
                          const SizedBox(height: 22),
                          StatusPillsRow(
                            items: [
                              StatusPillItem(
                                value: '$pendingCount',
                                label: 'En attente',
                                valueColor: AppColors.warn,
                              ),
                              StatusPillItem(
                                value: '$acceptedCount',
                                label: 'Acceptées',
                                valueColor: AppColors.success,
                              ),
                              StatusPillItem(
                                value: '$acceptanceRate%',
                                label: 'Taux acceptation',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          DemarcheurReferralsSection(
                            referrals: referrals,
                            sourceById: sourceById,
                            onSeeAll: _onOpenAllReferrals,
                            onAddReferral: _onOpenNew,
                            onReferralTap: _onOpenReferralDetail,
                          ),
                          const SizedBox(height: 6),
                          DemarcheurListingsToPushSection(
                            appartements: pushApparts,
                            onListingTap: _onOpenNewForAppart,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Astuce : les biens à forte note convertissent +30 %.',
                            style: AppTextStyles.small.copyWith(fontSize: 12),
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
