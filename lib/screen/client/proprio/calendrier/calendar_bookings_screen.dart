import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/availability_bloc/availability_bloc.dart';
import 'package:asfar/bloc/availability_bloc/availability_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/calendar_legend.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_grid.dart';
import 'package:asfar/screen/client/proprio/calendrier/manual_reservation_wizard_screen.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/appartement_chips_row.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/block_period_dialog.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_stats_row.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_tip_banner.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/manual_reservation_action_sheet.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/month_bookings_list.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/selected_appart_header.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/manque_a_gagner_calculator.dart';
import 'package:asfar/util/calc/tip_suggestion_engine.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Calendrier & bookings » du proprio — vue agenda multi-annonces.
///
/// - Chips horizontales (sticky) pour switcher d'annonce
/// - Header annonce (thumb + titre + commune + prix/n)
/// - 3 stats Occupé / Libre / Manque à gagner
/// - Calendrier mensuel (`MiniCalendarGrid` réutilisé)
/// - Bandeau Conseil conditionnel (`TipSuggestionEngine`)
/// - Liste « Réservations du mois » de l'annonce sélectionnée
/// - CTA « + Réserver pour un client direct » ouvre le wizard
class CalendarBookingsScreen extends StatefulWidget {
  final int? initialAppartementId;

  const CalendarBookingsScreen({super.key, this.initialAppartementId});

  @override
  State<CalendarBookingsScreen> createState() => _CalendarBookingsScreenState();
}

class _CalendarBookingsScreenState extends State<CalendarBookingsScreen> {
  Appartement? _selected;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSelection());
  }

  void _initSelection() {
    if (!mounted) return;
    final apparts = context.read<AppartementBloc>().state.appartements;
    if (apparts.isEmpty) return;
    final initial = widget.initialAppartementId == null
        ? apparts.first
        : apparts.firstWhere(
            (a) => a.id == widget.initialAppartementId,
            orElse: () => apparts.first,
          );
    setState(() => _selected = initial);
    _loadDataFor(initial);
  }

  void _loadDataFor(Appartement a) {
    final id = a.id;
    if (id == null) return;
    final debut = _currentMonth;
    final fin = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    context.read<CalendarPlageBloc>().add(LoadCalendarPlages(
          appartId: id,
          debut: debut,
          fin: fin,
          isDemarcheur: false,
        ));
    context.read<AvailabilityBloc>().add(LoadAvailability(id));
  }

  void _onSelectAppart(Appartement a) {
    setState(() => _selected = a);
    _loadDataFor(a);
  }

  void _onPrevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    if (_selected != null) _loadDataFor(_selected!);
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    if (_selected != null) _loadDataFor(_selected!);
  }

  Future<void> _openActionSheet() async {
    if (_selected == null) return;
    final action = await ManualReservationActionSheet.show(context);
    if (!mounted || action == null) return;
    switch (action) {
      case ManualReservationAction.block:
        await _openBlockDialog();
        return;
      case ManualReservationAction.reserve:
        _openWizard();
        return;
    }
  }

  Future<void> _openBlockDialog() async {
    final range = await BlockPeriodDialog.show(context);
    if (!mounted || range == null || _selected == null) return;
    context
        .read<AvailabilityBloc>()
        .add(BlockDates(_selected!.id!, range));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Période bloquée'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openWizard() {
    if (_selected == null) return;
    pushScreen(
      context,
      ManualReservationWizardScreen(appartement: _selected!),
    ).then((_) {
      if (!mounted || _selected == null) return;
      _loadDataFor(_selected!); // refresh au retour
    });
  }

  void _openReservationDetail(Reservation r) {
    pushScreen(context, ReservationDetailScreen(reservation: r));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Calendrier',
        eyebrow: 'TOUTES MES ANNONCES',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: IconBoutton(
          icon: Icons.add,
          onPressed: _selected == null ? null : _openActionSheet,
        ),
      ),
      floatingActionButton: _selected == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              icon: const Icon(Icons.add),
              label: const Text('Bloquer / Réserver'),
              onPressed: _openActionSheet,
            ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, appartState) {
            final apparts = appartState.appartements;
            if (apparts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState.hero(
                  icon: Icons.calendar_today_outlined,
                  title: 'Aucune annonce',
                  body:
                      'Créez votre première annonce pour voir son calendrier ici.',
                ),
              );
            }
            return NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ChipsHeaderDelegate(
                    apparts: apparts,
                    selectedId: _selected?.id,
                    onSelect: _onSelectAppart,
                  ),
                ),
              ],
              body: _selected == null
                  ? const SizedBox.shrink()
                  : _CalendarContent(
                      appartement: _selected!,
                      currentMonth: _currentMonth,
                      onPrevMonth: _onPrevMonth,
                      onNextMonth: _onNextMonth,
                      onOpenWizard: _openWizard,
                      onTapReservation: _openReservationDetail,
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Sliver header pinned avec la row de chips.
class _ChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<Appartement> apparts;
  final int? selectedId;
  final void Function(Appartement) onSelect;

  _ChipsHeaderDelegate({
    required this.apparts,
    required this.selectedId,
    required this.onSelect,
  });

  static const double _height = 48;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Container avec height explicite = match exact entre layoutExtent et
    // paintExtent (sinon SliverGeometry assertion : paintExtent < layoutExtent).
    return Container(
      height: _height,
      color: AppColors.background,
      child: AppartementChipsRow(
        appartements: apparts,
        selectedId: selectedId,
        onSelect: onSelect,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ChipsHeaderDelegate oldDelegate) =>
      oldDelegate.selectedId != selectedId ||
      oldDelegate.apparts.length != apparts.length;
}

/// Contenu sous les chips : header annonce + stats + calendrier + conseil +
/// liste réservations + CTA.
class _CalendarContent extends StatelessWidget {
  final Appartement appartement;
  final DateTime currentMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onOpenWizard;
  final void Function(Reservation) onTapReservation;

  const _CalendarContent({
    required this.appartement,
    required this.currentMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onOpenWizard,
    required this.onTapReservation,
  });

  List<int> _daysWith(List<CalendarPlage> plages, PlageStatut statut) {
    final days = <int>{};
    for (final p in plages.where((p) => p.statut == statut)) {
      var cursor = DateTime(p.debut.year, p.debut.month, p.debut.day);
      final end = DateTime(p.fin.year, p.fin.month, p.fin.day);
      while (cursor.isBefore(end)) {
        if (cursor.year == currentMonth.year &&
            cursor.month == currentMonth.month) {
          days.add(cursor.day);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days.toList();
  }

  int _joursDistincts(List<CalendarPlage> plages, Set<PlageStatut> statuts) {
    final days = <DateTime>{};
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    for (final p in plages.where((p) => statuts.contains(p.statut))) {
      var cursor = DateTime(p.debut.year, p.debut.month, p.debut.day);
      final end = DateTime(p.fin.year, p.fin.month, p.fin.day);
      while (cursor.isBefore(end)) {
        if (!cursor.isBefore(monthStart) && !cursor.isAfter(monthEnd)) {
          days.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days.length;
  }

  List<Reservation> _reservationsDuMois(List<Reservation> all) {
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final monthEnd =
        DateTime(currentMonth.year, currentMonth.month + 1, 0, 23, 59, 59);
    return all.where((r) {
      if (r.appart?.id != appartement.id) return false;
      if (r.statut == ReservationStatus.annulee) {
        return false;
      }
      if (r.debut == null || r.fin == null) return false;
      // Overlap: r.debut <= monthEnd ET r.fin >= monthStart
      return !r.debut!.isAfter(monthEnd) && !r.fin!.isBefore(monthStart);
    }).toList()
      ..sort((a, b) => (a.debut ?? DateTime(0)).compareTo(b.debut ?? DateTime(0)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarPlageBloc, CalendarPlageState>(
      builder: (context, plageState) {
        final plages = (plageState is CalendarPlagesLoaded &&
                plageState.appartId == appartement.id)
            ? plageState.plages
            : <CalendarPlage>[];

        final bookedDays = _daysWith(plages, PlageStatut.occupe);
        final pendingDays = _daysWith(plages, PlageStatut.enAttente);
        final blockedDays = _daysWith(plages, PlageStatut.disponible);

        final joursOccupes = _joursDistincts(
          plages,
          {PlageStatut.occupe, PlageStatut.enAttente},
        );
        final joursBloques = _joursDistincts(plages, {PlageStatut.disponible});
        final daysInMonth =
            DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
        final joursLibres = daysInMonth - joursOccupes - joursBloques;

        final prixNuit = (appartement.prix ?? 0).round();
        final manque = ManqueAGagnerCalculator.computeForMonth(
          plages: plages,
          prixNuit: prixNuit,
          year: currentMonth.year,
          month: currentMonth.month,
        );

        final tip = TipSuggestionEngine.computeForCurrentWeek(
          plages: plages,
          prixNuit: prixNuit,
        );

        return BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, resState) {
            final reservationsMois = _reservationsDuMois(resState.reservations);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
              children: [
                SelectedAppartHeader(appartement: appartement),
                const SizedBox(height: 14),
                CalendarStatsRow(
                  joursOccupes: joursOccupes,
                  joursLibres: joursLibres,
                  manqueAGagnerFcfa: manque,
                ),
                const SizedBox(height: 16),
                MiniCalendarGrid(
                  currentMonth: currentMonth,
                  bookedDays: bookedDays,
                  pendingDays: pendingDays,
                  blockedDays: blockedDays,
                  onPrevMonth: onPrevMonth,
                  onNextMonth: onNextMonth,
                ),
                const SizedBox(height: 10),
                const CalendarLegend(),
                // « Conseil du jour » masqué (réunion 17/05). Le calcul amont
                // (`tip`) est conservé pour réactivation ultérieure.
                // ignore: dead_code
                if (false && tip != null) ...[
                  const SizedBox(height: 16),
                  CalendarTipBanner(suggestion: tip),
                ],
                const SizedBox(height: 24),
                MonthBookingsList(
                  reservations: reservationsMois,
                  onTap: onTapReservation,
                ),
                const SizedBox(height: 16),
                OutlinedCustomButton(
                  text: '+ Réserver pour un client direct',
                  onPressed: onOpenWizard,
                  size: ButtonSize.lg,
                  block: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Vous pouvez ajouter manuellement les réservations qui n\'arrivent pas via Asfar (clients fidèles, paiement en espèces…).',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    color: AppColors.line,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
