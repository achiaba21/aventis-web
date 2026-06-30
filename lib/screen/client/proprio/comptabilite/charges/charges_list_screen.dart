import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/charge_filter_cubit/charge_filter_cubit.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/charge_detail_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/charge_form_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_appartement_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_filter_bar.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_period_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_row.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_type_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charges_empty_view.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charges_loading_view.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charges_total_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/charges_total.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran liste des charges du propriétaire — accessible depuis Finances.
///
/// Sémantique post-2026-05-13 : chaque charge = un paiement déjà enregistré.
/// Plus de bannière "en retard", plus de swipe-to-pay. Filtres restants :
/// appartement / type / période.
class ChargesListScreen extends StatelessWidget {
  const ChargesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChargeFilterCubit(),
      child: const _ChargesListView(),
    );
  }
}

class _ChargesListView extends StatefulWidget {
  const _ChargesListView();

  @override
  State<_ChargesListView> createState() => _ChargesListViewState();
}

class _ChargesListViewState extends State<_ChargesListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final apparts = context.read<AppartementBloc>().state.appartements;
      context.read<ChargeBloc>().setAppartements(apparts);
      context.read<ChargeBloc>().add(LoadCharges());
    });
  }

  void _onCreate() {
    pushScreen(context, const ChargeFormScreen.create());
  }

  void _onTapCharge(Charge c) {
    pushScreen(context, ChargeDetailScreen(charge: c));
  }

  Future<void> _onTapAppartPicker() async {
    final filterCubit = context.read<ChargeFilterCubit>();
    final apparts = context.read<AppartementBloc>().state.appartements;
    final result = await ChargeAppartementPicker.show(
      context,
      appartements: apparts,
      selectedId: filterCubit.state.appartementId,
    );
    if (result == null) return;
    filterCubit.setAppartement(result == -1 ? null : result);
  }

  Future<void> _onTapTypePicker() async {
    final filterCubit = context.read<ChargeFilterCubit>();
    final t = await ChargeTypePicker.show(
      context,
      selected: filterCubit.state.typeCharge,
    );
    filterCubit.setType(t);
  }

  Future<void> _onTapPeriodPicker() async {
    final filterCubit = context.read<ChargeFilterCubit>();
    final result = await ChargePeriodPicker.show(
      context,
      year: filterCubit.state.year,
      month: filterCubit.state.month,
    );
    if (result == null) return;
    filterCubit.setPeriod(year: result.year, month: result.month);
  }

  String _appartLabel(ChargeFilterState state) {
    if (state.appartementId == null) return 'Appartement';
    final apparts = context.read<AppartementBloc>().state.appartements;
    try {
      final a = apparts.firstWhere((x) => x.id == state.appartementId);
      return a.titre ?? 'Appartement';
    } catch (_) {
      return 'Appartement';
    }
  }

  String _periodLabel(ChargeFilterState state) {
    if (state.month == 0) return '${state.year}';
    const monthsShort = [
      '', 'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
    ];
    return '${monthsShort[state.month]} ${state.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes charges',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        onPressed: _onCreate,
        // Icône explicite « ajouter une charge » (reçu + plus) plutôt qu'un
        // simple « + » générique (réunion 17/05 & 24/05).
        child: const Icon(Icons.post_add_outlined),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ChargeFilterCubit, ChargeFilterState>(
          builder: (context, filterState) {
            return BlocBuilder<ChargeBloc, ChargeState>(
              builder: (context, chargeState) {
                final all = chargeState.charges;
                final isLoading =
                    chargeState is ChargeLoading && all.isEmpty;
                final filtered = filterState.apply(all);
                final hasAppartements = context
                    .read<AppartementBloc>()
                    .state
                    .appartements
                    .isNotEmpty;

                return Column(
                  children: [
                    ChargeFilterBar(
                      state: filterState,
                      onTapAppart: _onTapAppartPicker,
                      onTapType: _onTapTypePicker,
                      onTapPeriod: _onTapPeriodPicker,
                      appartLabel: _appartLabel(filterState),
                      periodLabel: _periodLabel(filterState),
                    ),
                    const SizedBox(height: 12),
                    if (!isLoading && filtered.isNotEmpty) ...[
                      ChargesTotalHeader(
                        count: filtered.length,
                        total: ChargesTotal.sum(filtered),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: isLoading
                          ? const ChargesLoadingView()
                          : filtered.isEmpty
                              ? ChargesEmptyView(
                                  hasFilters: filterState.hasActiveFilters,
                                  hasAppartements: hasAppartements,
                                  onCreateCharge: _onCreate,
                                  onClearFilters: () => context
                                      .read<ChargeFilterCubit>()
                                      .reset(),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      18, 0, 18, 96),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) {
                                    final c = filtered[i];
                                    return ChargeRow(
                                      charge: c,
                                      onTap: () => _onTapCharge(c),
                                    );
                                  },
                                ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
