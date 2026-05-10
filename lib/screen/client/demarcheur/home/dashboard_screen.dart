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
import 'package:asfar/screen/client/demarcheur/home/widget/listing_push_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/send_referral_cta_card.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pills_row.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/wallet_hero_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/new_referral_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referrals_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/mapping/reservation_to_referral.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Dashboard du Démarcheur — Vague 6.
///
/// V8.5 Lot 6 : branché sur `DemarcheurBloc` (réservations référencées) +
/// `CompteBloc` (solde wallet) + `AppartementBloc` (logements à pousser).
/// Les KPI (commission mois, delta, total, en attente, clients) sont
/// calculés via `DemarcheurStatsCalculator`. Plus aucun mock `SampleReferrals`
/// ni `SampleListingsToReferral`.
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

  void _onOpenNew(BuildContext context) {
    pushScreen(context, const NewReferralScreen());
  }

  void _onOpenNewForAppart(BuildContext context, Appartement appart) {
    pushScreen(
      context,
      NewReferralScreen(initialAppartement: appart),
    );
  }

  void _onOpenReferralDetail(
    BuildContext context,
    ReferralPreview r,
    Reservation? source,
  ) {
    pushScreen(
      context,
      ReferralDetailScreen(referral: r, source: source),
    );
  }

  void _onOpenAllReferrals(BuildContext context) {
    pushScreen(context, const DemarcheurReferralsScreen());
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
                    return _buildContent(
                      context,
                      reservations: reservations,
                      pushAppartements: appState.appartements,
                      solde: solde,
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

  List<Reservation> _extractReservations(DemarcheurState state) {
    if (state is DemarcheurReservationsLoaded) return state.reservations;
    return const [];
  }

  Widget _buildContent(
    BuildContext context, {
    required List<Reservation> reservations,
    required List<Appartement> pushAppartements,
    required int solde,
  }) {
    final monthCommission =
        DemarcheurStatsCalculator.monthCommission(reservations);
    final delta = DemarcheurStatsCalculator.deltaPercent(reservations);
    final totalCommission = solde > 0
        ? solde
        : DemarcheurStatsCalculator.totalCommission(reservations);
    final pendingCommission =
        DemarcheurStatsCalculator.pendingCommission(reservations);
    final clientsCount = DemarcheurStatsCalculator.clientsCount(reservations);
    final pendingCount = DemarcheurStatsCalculator.pendingCount(reservations);
    final acceptedCount = DemarcheurStatsCalculator.acceptedCount(reservations);
    final acceptanceRate =
        DemarcheurStatsCalculator.acceptanceRate(reservations);

    final allReferrals = ReservationToReferralMapper.mapMany(reservations);
    final referrals = allReferrals.take(3).toList();
    final sourceById = <String, Reservation>{
      for (var i = 0; i < allReferrals.length && i < reservations.length; i++)
        allReferrals[i].id: reservations[i],
    };

    final pushApparts = _topAppartsToPush(pushAppartements);

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
          SendReferralCtaCard(onTap: () => _onOpenNew(context)),
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
          SectionHeader(
            title: 'Mes clients référés',
            actionLabel: 'Tout voir',
            onActionTap: () => _onOpenAllReferrals(context),
          ),
          if (referrals.isEmpty)
            EmptyState.inline(
              icon: Icons.people_outline,
              title: 'Aucun client référé',
              body:
                  'Envoyez votre première demande pour commencer à gagner des commissions.',
              ctaLabel: 'Nouvelle demande',
              onCtaTap: () => _onOpenNew(context),
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
                  for (var i = 0; i < referrals.length; i++)
                    ReferralRow(
                      referral: referrals[i],
                      isLast: i == referrals.length - 1,
                      onTap: () => _onOpenReferralDetail(
                          context, referrals[i], sourceById[referrals[i].id]),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          SectionHeader(
            title: 'Logements à pousser',
            actionLabel: 'Voir tout',
            onActionTap: () {},
          ),
          if (pushApparts.isEmpty)
            EmptyState.inline(
              icon: Icons.home_work_outlined,
              title: 'Aucun logement disponible',
              body: 'Les logements éligibles apparaîtront ici.',
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: pushApparts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final a = pushApparts[i];
                  final l = AppartementToListingMapper.mapOne(a);
                  return ListingPushCard(
                    listing: l,
                    estimatedCommission: ReferralCommissionHelper.estimate(
                        pricePerNight: l.price),
                    onTap: () => _onOpenNewForAppart(context, a),
                  );
                },
              ),
            ),
          const SizedBox(height: 22),
          Text(
            'Astuce : les biens à forte note convertissent +30 %.',
            style: AppTextStyles.small.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Top 5 appartements à pousser, triés par note décroissante (proxy de
  /// performance). Renvoie les `Appartement` sources pour permettre la
  /// pré-sélection dans `NewReferralScreen`.
  List<Appartement> _topAppartsToPush(List<Appartement> apparts) {
    if (apparts.isEmpty) return const [];
    final sorted = List.of(apparts)
      ..sort((a, b) => (b.note).compareTo(a.note));
    return sorted.take(5).toList();
  }
}
