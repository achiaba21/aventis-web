import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_state.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/demarcheur_listings_to_push_section.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/demarcheur_referrals_section.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/send_referral_cta_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pills_row.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/wallet_hero_card.dart';
import 'package:asfar/screen/client/demarcheur/detail/demarcheur_appart_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/listings/demarcheur_listings_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referrals_screen.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Dashboard du Démarcheur — Vague 6.
class DemarcheurDashboard extends StatefulWidget {
  /// Prénom de l'utilisateur connecté (peut être null si l'utilisateur n'a
  /// pas renseigné de prénom). Le greeting s'adapte en conséquence — pas de
  /// valeur d'exemple en dur.
  final String? firstName;

  /// Callback fournie par le [DemarcheurShell] pour basculer d'onglet sans
  /// pusher une nouvelle route — utilisée par les « Voir tout » qui pointent
  /// vers une page déjà présente dans la BottomNav (ex : onglet Demandes).
  final void Function(int index)? onSwitchTab;

  const DemarcheurDashboard({
    super.key,
    this.firstName,
    this.onSwitchTab,
  });

  @override
  State<DemarcheurDashboard> createState() => _DemarcheurDashboardState();
}

class _DemarcheurDashboardState extends State<DemarcheurDashboard> {
  /// Décalage en mois par rapport au mois courant. 0 = mois courant,
  /// 1 = mois précédent, etc. Toujours ≥ 0 (on ne va jamais dans le futur).
  int _monthsBack = 0;

  static const _monthsLong = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DemarcheurBloc>().add(LoadDemarcheurReservations());
      context.read<DemarcheurBloc>().add(LoadDemarcheurAppartements());
      context.read<CompteBloc>().add(LoadCompte());
    });
  }

  DateTime get _referenceMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month - _monthsBack, 1);
  }

  DateTime get _previousMonth {
    final ref = _referenceMonth;
    return DateTime(ref.year, ref.month - 1, 1);
  }

  String _monthLabel(DateTime d) {
    final name = _monthsLong[d.month - 1];
    return '$name ${d.year}';
  }

  String _monthShortLabel(DateTime d) => _monthsLong[d.month - 1];

  void _onPrevMonth() => setState(() => _monthsBack += 1);

  void _onNextMonth() {
    if (_monthsBack == 0) return;
    setState(() => _monthsBack -= 1);
  }

  void _onOpenNew() =>
      pushScreen(context, const DemarcheurListingsScreen());

  void _onOpenNewForAppart(Appartement appart) {
    pushScreen(
      context,
      DemarcheurAppartDetailScreen(appartement: appart),
    );
  }

  void _onOpenReferralDetail(Reservation reservation) {
    pushScreen(context, ReferralDetailScreen(reservation: reservation));
  }

  void _onOpenAllReferrals() {
    final switchTab = widget.onSwitchTab;
    if (switchTab != null) {
      switchTab(1);
      return;
    }
    pushScreen(context, const DemarcheurReferralsScreen());
  }

  void _onOpenAllListings() =>
      pushScreen(context, const DemarcheurListingsScreen());

  List<Reservation> _extractReservations(DemarcheurState state) {
    if (state is DemarcheurDataLoaded) return state.reservations;
    return const [];
  }

  List<Appartement> _extractAppartements(DemarcheurState state) {
    if (state is DemarcheurDataLoaded) return state.appartements;
    return const [];
  }

  /// Top 5 appartements partenaires, triés par note décroissante.
  /// Utilise `rating` (non-nullable, dérive `note ?? avgCommentaires ?? 0.0`).
  List<Appartement> _topAppartsToPush(List<Appartement> apparts) {
    if (apparts.isEmpty) return const [];
    final sorted = List.of(apparts)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName?.trim() ?? '';
    final title = firstName.isEmpty ? 'Bonjour' : 'Bonjour, $firstName';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: title,
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
            final appartements = _extractAppartements(demarState);
            return BlocBuilder<CompteBloc, CompteState>(
                  builder: (context, compteState) {
                    final solde = compteState is CompteLoaded
                        ? (compteState.compte.solde ?? 0).round()
                        : 0;

                    final ref = _referenceMonth;
                    final monthCommission =
                        DemarcheurStatsCalculator.commissionForMonth(
                            reservations, ref.year, ref.month);
                    final delta =
                        DemarcheurStatsCalculator.deltaPercentForMonth(
                            reservations, ref.year, ref.month);
                    final totalCommission = solde > 0
                        ? solde
                        : DemarcheurStatsCalculator
                            .totalCommission(reservations);
                    final pendingCommission = DemarcheurStatsCalculator
                        .pendingCommissionForMonth(
                            reservations, ref.year, ref.month);
                    final clientsCount =
                        DemarcheurStatsCalculator.clientsCountForMonth(
                            reservations, ref.year, ref.month);
                    final pendingCount =
                        DemarcheurStatsCalculator.pendingCountForMonth(
                            reservations, ref.year, ref.month);
                    final acceptedCount =
                        DemarcheurStatsCalculator.acceptedCountForMonth(
                            reservations, ref.year, ref.month);
                    final acceptanceRate =
                        DemarcheurStatsCalculator.acceptanceRateForMonth(
                            reservations, ref.year, ref.month);

                    final referrals = reservations.take(3).toList();
                    final pushApparts = _topAppartsToPush(appartements);

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
                            monthLabel: _monthLabel(ref),
                            previousMonthLabel:
                                _monthShortLabel(_previousMonth),
                            onPrevMonth: _onPrevMonth,
                            onNextMonth:
                                _monthsBack == 0 ? null : _onNextMonth,
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
                            reservations: referrals,
                            onSeeAll: _onOpenAllReferrals,
                            onAddReferral: _onOpenNew,
                            onReferralTap: _onOpenReferralDetail,
                          ),
                          const SizedBox(height: 6),
                          DemarcheurListingsToPushSection(
                            appartements: pushApparts,
                            onListingTap: _onOpenNewForAppart,
                            onSeeAll: _onOpenAllListings,
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
        ),
      ),
    );
  }
}
