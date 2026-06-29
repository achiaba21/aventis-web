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
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/charges_list_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/benefice_net_hero_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/export_bottom_sheet.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/period_switcher.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/pnl_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/property_perf_list.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/year_selector.dart';
import 'package:asfar/service/export/export_share_helper.dart';
import 'package:asfar/service/export/finances_csv_exporter.dart';
import 'package:asfar/service/export/finances_pdf_exporter.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/pnl_aggregator.dart';
import 'package:asfar/util/calc/property_perf_aggregator.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Finances P&L — onglet Finances du `ProprioShell`.
///
/// État local :
/// - `_year` : année sélectionnée (max = année courante)
/// - `_period` : granularité (Semaine / Mois / Trimestre)
/// - `_index` : index dans la période (0..N selon le type)
///
/// Toutes les agrégations sont paramétrées par cette triplet via les
/// nouveaux calculators `PnLAggregator.forPeriod` /
/// `PropertyPerfAggregator.forPeriod`. La `ProjectionChart` reste basée
/// sur le présent (7 mois autour de now).
class ProprioFinancesScreen extends StatefulWidget {
  const ProprioFinancesScreen({super.key});

  @override
  State<ProprioFinancesScreen> createState() => _ProprioFinancesScreenState();
}

class _ProprioFinancesScreenState extends State<ProprioFinancesScreen> {
  late int _year;
  late FinancePeriod _period;
  late int _index;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _period = FinancePeriod.month;
    _index = _period.indexOf(_year, now);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  void _onExportTap() {
    ExportBottomSheet.show(
      context,
      onPdfTap: _exportPdf,
      onCsvTap: _exportCsv,
    );
  }

  Future<void> _exportPdf() async {
    final userState = context.read<UserBloc>().state;
    final user = userState.user;
    if (user == null) {
      _toast('Utilisateur non chargé');
      return;
    }
    try {
      final reservations =
          context.read<ReservationBloc>().state.reservations;
      final charges = _chargesFromBloc();
      final pnl = PnLAggregator.forPeriod(
        reservations: reservations,
        charges: charges,
        period: _period,
        year: _year,
        index: _index,
      );
      final prev = _period.previousAnchor(_year, _index);
      final pnlPrev = PnLAggregator.forPeriod(
        reservations: reservations,
        charges: charges,
        period: _period,
        year: prev.year,
        index: prev.index,
      );
      final deltaPercent = _delta(pnl.netIncome.amount, pnlPrev.netIncome.amount);
      final appartements =
          context.read<AppartementBloc>().state.appartements;
      final perfs = PropertyPerfAggregator.forPeriod(
        appartements: appartements,
        reservations: reservations,
        period: _period,
        year: _year,
        index: _index,
      ).where((p) => p.monthlyRevenue > 0 || p.occupancyRate > 0).toList();
      final encaissed = reservations
          .where((r) =>
              r.isEncaissed &&
              r.debut != null &&
              _period.contains(_year, _index, r.debut!))
          .toList();

      final bytes = await FinancesPdfExporter.build(
        proprio: user,
        period: _period,
        year: _year,
        index: _index,
        pnl: pnl,
        previousBeneficeAmount: pnlPrev.netIncome.amount,
        beneficeDeltaPercent: deltaPercent,
        perfs: perfs,
        reservationsEncaissed: encaissed,
      );

      final fileName = ExportShareHelper.buildFileName(
        periodSlug: _periodSlug(),
        generatedAt: DateTime.now(),
        extension: 'pdf',
      );
      if (!mounted) return;
      await ExportShareHelper.previewPdf(
        context: context,
        bytes: bytes,
        fileName: fileName,
        title: 'Rapport ${_period.longLabel(_year, _index)}',
      );
    } catch (e) {
      deboger('FinancesExport.pdf: $e');
      if (mounted) _toast('Erreur génération PDF');
    }
  }

  Future<void> _exportCsv() async {
    try {
      final reservations =
          context.read<ReservationBloc>().state.reservations;
      final encaissed = reservations
          .where((r) =>
              r.isEncaissed &&
              r.debut != null &&
              _period.contains(_year, _index, r.debut!))
          .toList();

      final csv = FinancesCsvExporter.build(
        period: _period,
        year: _year,
        index: _index,
        reservationsEncaissed: encaissed,
      );
      final fileName = ExportShareHelper.buildFileName(
        periodSlug: _periodSlug(),
        generatedAt: DateTime.now(),
        extension: 'csv',
      );
      await ExportShareHelper.shareCsv(content: csv, fileName: fileName);
    } catch (e) {
      deboger('FinancesExport.csv: $e');
      if (mounted) _toast('Erreur génération CSV');
    }
  }

  List<Charge> _chargesFromBloc() {
    final state = context.read<ChargeBloc>().state;
    return state is ChargeLoaded ? state.charges : const <Charge>[];
  }

  String _periodSlug() {
    final p = _period.switcherLabel.toLowerCase();
    return '${_year}_${p}_${_index + 1}';
  }

  bool get _isCurrentYear => _year == DateTime.now().year;

  /// Borne supérieure : on ne dépasse pas la période en cours.
  int get _maxIndexForCurrentYear {
    final now = DateTime.now();
    if (_year < now.year) return _period.maxIndex(_year);
    if (_year > now.year) return 0;
    return _period.indexOf(_year, now);
  }

  bool get _canGoNextPeriod => _index < _maxIndexForCurrentYear;

  bool get _canGoPrevPeriod {
    // Recul libre, sauf si on est sur la 1ère période de la 1ère année
    // accessible. Comme on n'a pas de borne basse, toujours possible.
    return true;
  }

  void _onYearPrev() {
    setState(() {
      _year -= 1;
      _index = _index.clamp(0, _maxIndexForCurrentYear);
    });
  }

  void _onYearNext() {
    setState(() {
      _year += 1;
      _index = _index.clamp(0, _maxIndexForCurrentYear);
    });
  }

  void _onPeriodChange(FinancePeriod next) {
    if (next == _period) return;
    // En changeant de granularité, on conserve la date « centrale » : on
    // retombe sur l'index correspondant à la date de fin de la période
    // courante dans la nouvelle granularité.
    final pivot = _period.endOf(_year, _index);
    setState(() {
      _period = next;
      _index = next.indexOf(_year, pivot).clamp(0, _maxIndexForCurrentYear);
    });
  }

  void _onPeriodPrev() {
    final prev = _period.previousAnchor(_year, _index);
    final now = DateTime.now();
    if (prev.year > now.year) return;
    setState(() {
      _year = prev.year;
      _index = prev.index;
    });
  }

  void _onPeriodNext() {
    if (!_canGoNextPeriod) return;
    final next = _period.nextAnchor(_year, _index);
    final now = DateTime.now();
    if (next.year > now.year) return;
    if (next.year == now.year &&
        next.index > _period.indexOf(now.year, now)) {
      return;
    }
    setState(() {
      _year = next.year;
      _index = next.index;
    });
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
        trailingWidth: 40,
        trailing: IconBoutton(
          icon: Icons.download_outlined,
          onPressed: _onExportTap,
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

                    final pnl = PnLAggregator.forPeriod(
                      reservations: reservations,
                      charges: charges,
                      period: _period,
                      year: _year,
                      index: _index,
                    );
                    final prev = _period.previousAnchor(_year, _index);
                    final pnlPrev = PnLAggregator.forPeriod(
                      reservations: reservations,
                      charges: charges,
                      period: _period,
                      year: prev.year,
                      index: prev.index,
                    );
                    final beneficeAmount = pnl.netIncome.amount;
                    final beneficePrev = pnlPrev.netIncome.amount;
                    final deltaPercent = _delta(beneficeAmount, beneficePrev);

                    final perfs = PropertyPerfAggregator.forPeriod(
                      appartements: appartements,
                      reservations: reservations,
                      period: _period,
                      year: _year,
                      index: _index,
                    )
                        .where((p) =>
                            p.monthlyRevenue > 0 || p.occupancyRate > 0)
                        .toList(growable: false);
                    // Section projection masquée temporairement — voir
                    // commentaire plus bas dans le build (vers SectionHeader
                    // « Projection 3 mois »).
                    // final projection =
                    //     ProjectionCalculator.sevenMonths(reservations);
                    // final q1 =
                    //     ProjectionCalculator.q1Estimation(reservations);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: YearSelector(
                              year: _year,
                              canGoPrev: true,
                              canGoNext: !_isCurrentYear,
                              onPrev: _onYearPrev,
                              onNext: _onYearNext,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PeriodSwitcher(
                            options: const ['Semaine', 'Mois', 'Trimestre'],
                            selected: _period.switcherLabel,
                            onSelect: (label) {
                              for (final p in FinancePeriod.values) {
                                if (p.switcherLabel == label) {
                                  _onPeriodChange(p);
                                  return;
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          BeneficeNetHeroCard(
                            amount: beneficeAmount,
                            previousAmount: beneficePrev,
                            deltaPercent: deltaPercent,
                            pipelineAmount: pnl.pipelineRevenue,
                            period: _period,
                            year: _year,
                            index: _index,
                            canGoPrev: _canGoPrevPeriod,
                            canGoNext: _canGoNextPeriod,
                            onPrev: _onPeriodPrev,
                            onNext: _onPeriodNext,
                          ),
                          const SizedBox(height: 22),
                          const Text('Compte de résultat',
                              style: AppTextStyles.h3),
                          const SizedBox(height: 12),
                          if (pnl.isEmpty)
                            EmptyState.inline(
                              icon: Icons.receipt_long_outlined,
                              title: 'Aucun mouvement sur cette période',
                              body:
                                  'Le compte de résultat apparaîtra dès la première réservation encaissée.',
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
                          const Text('Performance par bien',
                              style: AppTextStyles.h3),
                          const SizedBox(height: 12),
                          PropertyPerfList(perfs: perfs),
                          // Section « Projection 3 mois » temporairement
                          // masquée — réactivation prévue après calibration
                          // du modèle d'extrapolation.
                          //
                          // const SizedBox(height: 22),
                          // const Text('Projection 3 mois',
                          //     style: AppTextStyles.h3),
                          // const SizedBox(height: 12),
                          // Container(
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.bgElev1,
                          //     borderRadius:
                          //         BorderRadius.circular(AppRadii.lg),
                          //     border: Border.all(
                          //         color: AppColors.line, width: 1),
                          //   ),
                          //   child: ProjectionChart(
                          //     points: projection,
                          //     q1Estimation: q1,
                          //   ),
                          // ),
                          const SizedBox(height: 22),
                          // Actions côte à côte : ajout d'une charge (primaire)
                          // + export PDF (secondaire). Demi-largeur chacune.
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Charge',
                                  onPressed: () => pushScreen(
                                      context, const ChargesListScreen()),
                                  size: ButtonSize.md,
                                  block: true,
                                  leadingIcon: Icons.post_add_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedCustomButton(
                                  text: 'Exporter en PDF',
                                  onPressed: _onExportTap,
                                  size: ButtonSize.md,
                                  block: true,
                                  leadingIcon: Icons.download_outlined,
                                ),
                              ),
                            ],
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

  int _delta(int current, int prev) {
    if (prev == 0) return current == 0 ? 0 : 100;
    return (((current - prev) / prev) * 100).round();
  }
}
