import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Bottom sheet pour sélectionner un démarcheur partenaire.
///
/// V1 : empty state — la liste des démarcheurs actifs est à brancher en V2
/// (via `PartenariatBloc` quand l'endpoint « partenariats acceptés » sera
/// disponible). Pour l'instant, retourne toujours `null`.
class DemarcheurPickerSheet extends StatelessWidget {
  const DemarcheurPickerSheet({super.key});

  /// Helper d'ouverture. Renvoie l'id démarcheur ou `null`.
  static Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => const DemarcheurPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.bgElev3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Démarcheur partenaire', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            EmptyState.inline(
              icon: Icons.handshake_outlined,
              title: 'Aucun partenariat actif',
              body:
                  'Vous devez d\'abord accepter un partenariat avec un démarcheur. La sélection détaillée arrivera en V2.',
            ),
            const SizedBox(height: 14),
            OutlinedCustomButton(
              text: 'Fermer',
              size: ButtonSize.md,
              block: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
