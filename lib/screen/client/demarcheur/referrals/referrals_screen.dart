import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/new_referral_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_filter_chips.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/mapping/reservation_to_referral.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran « Mes demandes » du Démarcheur — onglet Referrals.
///
/// V8.5 Lot 6 : branché sur `DemarcheurBloc`. Les referrals proviennent de
/// `DemarcheurReservationsLoaded.reservations` mappées via
/// `ReservationToReferralMapper`. EmptyState au lieu du Padding centré
/// du proto.
class DemarcheurReferralsScreen extends StatefulWidget {
  const DemarcheurReferralsScreen({super.key});

  @override
  State<DemarcheurReferralsScreen> createState() =>
      _DemarcheurReferralsScreenState();
}

class _DemarcheurReferralsScreenState extends State<DemarcheurReferralsScreen> {
  static const _filters = [
    'Toutes',
    'En attente',
    'Acceptées',
    'Terminées',
    'Refusées',
  ];

  String _filter = 'Toutes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DemarcheurBloc>().add(LoadDemarcheurReservations());
    });
  }

  ReferralStatus? _statusForFilter(String f) {
    switch (f) {
      case 'En attente':
        return ReferralStatus.pending;
      case 'Acceptées':
        return ReferralStatus.accepted;
      case 'Terminées':
        return ReferralStatus.completed;
      case 'Refusées':
        return ReferralStatus.refused;
      default:
        return null;
    }
  }

  void _onOpenNew() {
    pushScreen(context, const NewReferralScreen());
  }

  void _onOpenDetail(ReferralPreview referral) {
    pushScreen(context, ReferralDetailScreen(referral: referral));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes demandes',
        trailing: SizedBox(
          width: 96,
          child: CustomButton(
            text: 'Nouvelle',
            onPressed: _onOpenNew,
            size: ButtonSize.sm,
            block: true,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<DemarcheurBloc, DemarcheurState>(
          builder: (context, state) {
            if (state is DemarcheurLoading) return _buildLoading();
            if (state is DemarcheurError) {
              return EmptyState.error(
                message: state.message,
                onRetry: () => context
                    .read<DemarcheurBloc>()
                    .add(LoadDemarcheurReservations()),
              );
            }
            final reservations = state is DemarcheurReservationsLoaded
                ? state.reservations
                : <Reservation>[];
            final referrals =
                ReservationToReferralMapper.mapMany(reservations);
            final wanted = _statusForFilter(_filter);
            final visible = wanted == null
                ? referrals
                : referrals.where((r) => r.status == wanted).toList();
            return _buildContent(context, visible);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 80),
        SizedBox(height: 10),
        ShimmerCard(height: 80),
        SizedBox(height: 10),
        ShimmerCard(height: 80),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ReferralPreview> visible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        ReferralFilterChips(
          filters: _filters,
          selected: _filter,
          onSelect: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: visible.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: EmptyState.hero(
                    icon: Icons.people_outline,
                    title: _emptyTitleFor(_filter),
                    body: _emptyBodyFor(_filter),
                    ctaLabel: 'Nouvelle demande',
                    onCtaTap: _onOpenNew,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgElev1,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.line, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          ReferralRow(
                            referral: visible[i],
                            isLast: i == visible.length - 1,
                            onTap: () => _onOpenDetail(visible[i]),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _emptyTitleFor(String filter) {
    if (filter == 'Toutes') return 'Aucune demande envoyée';
    return 'Aucune demande $filter'.toLowerCase();
  }

  String _emptyBodyFor(String filter) {
    if (filter == 'Toutes') {
      return 'Référencez votre premier client pour commencer à gagner des commissions.';
    }
    return 'Aucune demande dans cette catégorie pour le moment.';
  }
}
