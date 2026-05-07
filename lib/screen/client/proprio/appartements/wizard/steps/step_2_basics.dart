import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/form/property_type_selector.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Étape 2 du wizard : titre + type de location.
class Step2Basics extends StatefulWidget {
  const Step2Basics({super.key});

  @override
  State<Step2Basics> createState() => _Step2BasicsState();
}

class _Step2BasicsState extends State<Step2Basics> {
  Timer? _titleDebounce;

  @override
  void dispose() {
    _titleDebounce?.cancel();
    super.dispose();
  }

  void _onTitleChanged(String? value) {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<AppartementWizardBloc>().add(
            UpdateField('titre', value ?? ''),
          );
    });
  }

  void _onTypeSelected(String type) {
    context.read<AppartementWizardBloc>().add(UpdateField('typeLocation', type));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
      buildWhen: (prev, next) =>
          prev.draft.titre != next.draft.titre ||
          prev.draft.typeLocation != next.draft.typeLocation ||
          prev.validationErrors != next.validationErrors,
      builder: (context, state) {
        final draft = state.draft;
        final showTitleError =
            (state.validationErrors['titre'] != null) &&
                (draft.titre?.trim().isEmpty ?? true);

        return SingleChildScrollView(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Décrivez votre bien",
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Espacement.gapItem),
              TextSeed(
                "Donnez un titre attrayant et choisissez le type de location.",
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: Espacement.gapSection * 2),
              TextSeed(
                "Titre",
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Espacement.gapItem),
              InputField(
                placeHolder: "Ex: Studio Cocody Angré, vue sur le jardin",
                initialValue: draft.titre,
                maxLength: 100,
                onChange: (value) {
                  _onTitleChanged(value);
                  return null;
                },
              ),
              if (showTitleError) ...[
                SizedBox(height: Espacement.gapItem),
                TextSeed(
                  state.validationErrors['titre']!,
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ],
              SizedBox(height: Espacement.gapSection * 2),
              TextSeed(
                "Type de location",
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Espacement.gapSection),
              PropertyTypeSelector(
                selectedType: draft.typeLocation,
                onTypeSelected: _onTypeSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
