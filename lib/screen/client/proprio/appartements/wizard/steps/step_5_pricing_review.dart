import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Étape 5 du wizard : preview de l'annonce, prix, récap validation,
/// hint cliquable vers les étapes manquantes.
class Step5PricingReview extends StatelessWidget {
  const Step5PricingReview({super.key});

  static const Map<String, int> _fieldToStep = {
    'address': 1,
    'titre': 2,
    'typeLocation': 2,
    'capacity': 3,
    'photos': 4,
    'prix': 5,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
      buildWhen: (prev, next) =>
          prev.draft != next.draft ||
          prev.canPublish != next.canPublish ||
          prev.validationErrors != next.validationErrors,
      builder: (context, state) {
        final draft = state.draft;
        final bloc = context.read<AppartementWizardBloc>();

        return SingleChildScrollView(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Aperçu de votre annonce",
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Espacement.gapItem),
              TextSeed(
                "Voici comment votre bien apparaîtra aux locataires.",
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: Espacement.gapSection),
              AppartementPreviewCard(appartement: draft),
              SizedBox(height: Espacement.gapSection * 2),
              TextSeed(
                "Prix par nuit (GHS)",
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Espacement.gapItem),
              NumberInputField(
                placeHolder: "25000",
                initialValue: draft.prix,
                allowDecimals: false,
                minValue: 0,
                onValueChanged: (value) {
                  bloc.add(UpdateField('prix', value ?? 0));
                },
              ),
              SizedBox(height: Espacement.gapSection * 2),
              _ValidationSummary(
                canPublish: state.canPublish,
                errors: state.validationErrors,
                onJumpToStep: (step) => bloc.add(GoToStep(step)),
                fieldToStep: _fieldToStep,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ValidationSummary extends StatelessWidget {
  const _ValidationSummary({
    required this.canPublish,
    required this.errors,
    required this.onJumpToStep,
    required this.fieldToStep,
  });

  final bool canPublish;
  final Map<String, String> errors;
  final ValueChanged<int> onJumpToStep;
  final Map<String, int> fieldToStep;

  @override
  Widget build(BuildContext context) {
    if (canPublish) {
      return Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            SizedBox(width: Espacement.gapSection),
            Expanded(
              child: TextSeed(
                "Tout est prêt pour publier",
                fontSize: 14,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.warning, size: 20),
              SizedBox(width: Espacement.gapSection),
              Expanded(
                child: TextSeed(
                  "Avant de publier, complétez :",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: Espacement.gapSection),
          ...errors.entries.map((entry) => _ErrorJumpItem(
                field: entry.key,
                message: entry.value,
                step: fieldToStep[entry.key],
                onTap: onJumpToStep,
              )),
        ],
      ),
    );
  }
}

class _ErrorJumpItem extends StatelessWidget {
  const _ErrorJumpItem({
    required this.field,
    required this.message,
    required this.step,
    required this.onTap,
  });

  final String field;
  final String message;
  final int? step;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: step == null ? null : () => onTap(step!),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Espacement.gapItem),
        child: Row(
          children: [
            Icon(Icons.arrow_right, size: 16, color: AppColors.warning),
            SizedBox(width: Espacement.gapItem),
            Expanded(
              child: TextSeed(
                message,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            if (step != null)
              TextSeed(
                "Corriger →",
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
          ],
        ),
      ),
    );
  }
}
