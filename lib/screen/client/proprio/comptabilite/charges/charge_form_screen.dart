import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_bloc.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_event.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_state.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/forms/charge_form_data.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_form_body.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran de création OU édition d'une charge.
///
/// `.create()` : champs vides, dispatch `AddCharge` via `ChargeBloc`.
/// `.edit(initial)` : pré-rempli, dispatch `UpdateChargeAction` via
/// `ChargeDetailBloc` (fourni en amont via `BlocProvider.value`).
///
/// L'écran ne gère que le wiring BLoC + le feedback (snackbar succès/erreur) ;
/// le formulaire lui-même vit dans `ChargeFormBody`.
class ChargeFormScreen extends StatelessWidget {
  final Charge? initial;

  const ChargeFormScreen.create({super.key}) : initial = null;
  const ChargeFormScreen.edit({super.key, required Charge this.initial});

  bool get isEdit => initial != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: isEdit ? 'Modifier la charge' : 'Nouvelle charge',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: isEdit
          ? BlocConsumer<ChargeDetailBloc, ChargeDetailState>(
              listener: _editListener,
              builder: (context, state) => ChargeFormBody(
                initial: initial,
                isLoading: state is ChargeDetailActionInProgress &&
                    state.action == ChargeDetailAction.edit,
                onSubmit: (data) => _submitEdit(context, data),
              ),
            )
          : BlocConsumer<ChargeBloc, ChargeState>(
              listener: _createListener,
              builder: (context, state) => ChargeFormBody(
                initial: null,
                isLoading: state is ChargeLoading,
                onSubmit: (data) => _submitCreate(context, data),
              ),
            ),
    );
  }

  void _submitCreate(BuildContext context, ChargeFormData d) {
    context.read<ChargeBloc>().add(AddCharge(
          appartementId: d.appartementId,
          typeCharge: d.typeCharge,
          libelle: d.libelle,
          montant: d.montant,
          frequence: d.frequence,
          dateDebut: d.dateDebut,
          dateEcheance: d.dateEcheance,
          notes: d.notes,
        ));
  }

  void _submitEdit(BuildContext context, ChargeFormData d) {
    final updated = initial!.copyWith(
      appartementId: d.appartementId,
      typeCharge: d.typeCharge,
      libelle: d.libelle,
      montant: d.montant,
      frequence: d.frequence,
      dateDebut: d.dateDebut,
      dateEcheance: d.dateEcheance,
      estRecurrent: d.frequence.isRecurrente,
      notes: d.notes,
    );
    context.read<ChargeDetailBloc>().add(UpdateChargeAction(updated));
  }

  void _createListener(BuildContext context, ChargeState state) {
    if (state is ChargeOperationSuccess) {
      _snack(context, state.message);
      back(context);
    } else if (state is ChargeError) {
      _snack(context, state.message, isError: true);
    }
  }

  void _editListener(BuildContext context, ChargeDetailState state) {
    if (state is ChargeDetailActionSuccess &&
        state.action == ChargeDetailAction.edit) {
      _snack(context, 'Charge modifiée');
      back(context);
    } else if (state is ChargeDetailActionError &&
        state.action == ChargeDetailAction.edit) {
      _snack(context, state.message, isError: true);
    }
  }

  void _snack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? AppColors.danger : null,
    ));
  }
}
