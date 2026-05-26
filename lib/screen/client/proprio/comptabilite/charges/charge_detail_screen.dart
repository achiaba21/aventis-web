import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_bloc.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_event.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_state.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/charge_form_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_actions_bar.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_appart_card.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_dates_section.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_header.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_meta_section.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_detail_montant_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/section/section_with_eyebrow.dart';

/// Écran détail d'une charge — proprio uniquement.
///
/// Actions : marquer payée/impayée, éditer, supprimer. Toutes les mutations
/// passent par `ChargeDetailBloc` qui notifie le `ChargeBloc` liste après
/// chaque succès API.
class ChargeDetailScreen extends StatelessWidget {
  final Charge charge;

  const ChargeDetailScreen({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChargeDetailBloc>(
      create: (ctx) {
        final bloc = ChargeDetailBloc(
          listBloc: ctx.read<ChargeBloc>(),
        );
        bloc.add(LoadCharge(charge));
        return bloc;
      },
      child: _ChargeDetailView(),
    );
  }
}

class _ChargeDetailView extends StatelessWidget {
  const _ChargeDetailView();

  Future<void> _confirmDelete(BuildContext context, Charge charge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.bgElev1,
        title: const Text(
          'Supprimer la charge',
          style: TextStyle(color: AppColors.text),
        ),
        content: const Text(
          'Cette charge sera définitivement supprimée. Confirmer ?',
          style: TextStyle(color: AppColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.text2),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ChargeDetailBloc>().add(DeleteChargeAction());
    }
  }

  void _onAction(
    BuildContext context,
    ChargeDetailAction action,
    Charge charge,
  ) {
    final bloc = context.read<ChargeDetailBloc>();
    switch (action) {
      case ChargeDetailAction.edit:
        pushScreen(
          context,
          BlocProvider<ChargeDetailBloc>.value(
            value: bloc,
            child: ChargeFormScreen.edit(initial: charge),
          ),
        );
        return;
      case ChargeDetailAction.delete:
        _confirmDelete(context, charge);
        return;
    }
  }

  void _handleActionResult(BuildContext context, ChargeDetailState state) {
    if (state is ChargeDetailActionSuccess) {
      final label = _successLabelOf(state.action);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
      ));
      if (state.action == ChargeDetailAction.delete) {
        back(context);
      }
    }
    if (state is ChargeDetailActionError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
      ));
    }
  }

  String _successLabelOf(ChargeDetailAction a) {
    switch (a) {
      case ChargeDetailAction.edit:
        return 'Charge modifiée';
      case ChargeDetailAction.delete:
        return 'Charge supprimée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Détail charge',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: BlocConsumer<ChargeDetailBloc, ChargeDetailState>(
        listener: _handleActionResult,
        builder: (context, state) {
          final charge = state.charge;
          if (charge == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChargeDetailHeader(charge: charge),
                  const SizedBox(height: 24),
                  SectionWithEyebrow(
                    label: 'MONTANT',
                    child: ChargeDetailMontantCard(charge: charge),
                  ),
                  const SizedBox(height: 24),
                  SectionWithEyebrow(
                    label: 'LOGEMENT',
                    child: ChargeDetailAppartCard(charge: charge),
                  ),
                  const SizedBox(height: 24),
                  SectionWithEyebrow(
                    label: 'DATES',
                    child: ChargeDetailDatesSection(charge: charge),
                  ),
                  if ((charge.notes ?? '').isNotEmpty ||
                      charge.createdAt != null) ...[
                    const SizedBox(height: 24),
                    Text('INFORMATIONS', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 10),
                    ChargeDetailMetaSection(charge: charge),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ChargeDetailBloc, ChargeDetailState>(
        builder: (context, state) {
          final charge = state.charge;
          if (charge == null) return const SizedBox.shrink();
          final actionInProgress = state is ChargeDetailActionInProgress
              ? state.action
              : null;
          return ChargeDetailActionsBar(
            actionInProgress: actionInProgress,
            onAction: (a) => _onAction(context, a, charge),
          );
        },
      ),
    );
  }
}
