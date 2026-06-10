import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Bloc d'actions de modération d'une annonce (côté propriétaire), affiché
/// dans `ProprioListingEditScreen`.
///
/// Le bouton dépend du statut (cf. machine à états backend) :
/// - `EN_LIGNE`   → « Mettre hors ligne »
/// - `HORS_LIGNE` → « Remettre en ligne »
/// - `REFUSER`    → message « refusée par la modération » + « Resoumettre »
/// - `EN_COURS`   → message « en attente », aucun bouton
///
/// Le motif détaillé d'un refus n'est pas exposé au propriétaire par le
/// backend : on affiche donc un message générique.
class ListingModerationActions extends StatelessWidget {
  final AppartementStatus? status;
  final VoidCallback onMettreHorsLigne;
  final VoidCallback onRemettreEnLigne;
  final VoidCallback onResoumettre;
  final bool busy;

  const ListingModerationActions({
    super.key,
    required this.status,
    required this.onMettreHorsLigne,
    required this.onRemettreEnLigne,
    required this.onResoumettre,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? action = switch (status) {
      AppartementStatus.EN_LIGNE => OutlinedCustomButton(
          text: 'Mettre hors ligne',
          leadingIcon: Icons.visibility_off_outlined,
          onPressed: busy ? null : onMettreHorsLigne,
          loading: busy,
          block: true,
        ),
      AppartementStatus.HORS_LIGNE => CustomButton(
          text: 'Remettre en ligne',
          leadingIcon: Icons.visibility_outlined,
          onPressed: busy ? null : onRemettreEnLigne,
          loading: busy,
          block: true,
        ),
      AppartementStatus.REFUSER => CustomButton(
          text: 'Resoumettre',
          leadingIcon: Icons.refresh,
          onPressed: busy ? null : onResoumettre,
          loading: busy,
          block: true,
        ),
      _ => null,
    };

    final ({String text, bool danger})? note = switch (status) {
      AppartementStatus.EN_COURS => (
          text: 'En attente de validation par la modération.',
          danger: false,
        ),
      AppartementStatus.REFUSER => (
          text: 'Annonce refusée par la modération.',
          danger: true,
        ),
      _ => null,
    };

    if (action == null && note == null) return const SizedBox.shrink();

    final children = <Widget>[];
    if (note != null) {
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            note.danger ? Icons.gpp_bad_outlined : Icons.hourglass_top,
            size: 18,
            color: note.danger ? AppColors.danger : AppColors.warn,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note.text,
              style: AppTextStyles.small.copyWith(
                fontSize: 13,
                color: note.danger ? AppColors.danger : AppColors.text2,
              ),
            ),
          ),
        ],
      ));
    }
    if (note != null && action != null) {
      children.add(const SizedBox(height: 14));
    }
    if (action != null) children.add(action);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
