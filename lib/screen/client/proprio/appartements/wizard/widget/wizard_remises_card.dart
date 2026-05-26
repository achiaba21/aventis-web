import 'package:flutter/material.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/reduction_palier_dialog.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card « Remises long séjour » du step 5 wizard.
///
/// Affiche la liste des paliers configurés (à partir de combien de nuits,
/// nouveau prix par nuit) + un CTA pour ajouter un palier. Réutilise le
/// dialog d'édition `ReductionPalierDialog` déjà en place pour l'écran
/// d'édition d'annonce.
///
/// La card est entièrement optionnelle : le proprio peut publier sans
/// remise. La liste est triée par seuil croissant.
class WizardRemisesCard extends StatelessWidget {
  final List<Condition> conditions;
  final void Function(Condition added) onAdd;
  final void Function(Condition oldValue, Condition newValue) onUpdate;
  final void Function(Condition removed) onDelete;

  const WizardRemisesCard({
    super.key,
    required this.conditions,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  List<Condition> get _sorted {
    final list = List<Condition>.from(conditions);
    list.sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));
    return list;
  }

  Future<void> _onAddTap(BuildContext context) async {
    final result = await ReductionPalierDialog.show(context);
    if (result == null) return;
    if (result.delete) return; // pas pertinent en création
    if (result.condition != null) onAdd(result.condition!);
  }

  Future<void> _onEditTap(BuildContext context, Condition c) async {
    final result = await ReductionPalierDialog.show(context, initial: c);
    if (result == null) return;
    if (result.delete) {
      onDelete(c);
      return;
    }
    if (result.condition != null) onUpdate(c, result.condition!);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'REMISES LONG SÉJOUR',
                  style: AppTextStyles.eyebrow,
                ),
              ),
              InkWell(
                onTap: () => _onAddTap(context),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Ajouter',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'À partir d\'un certain nombre de nuits, applique un prix journalier réduit. Optionnel.',
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: AppColors.text3,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Aucun palier configuré.',
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text3,
                ),
              ),
            )
          else
            for (var i = 0; i < sorted.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.line),
              _PalierRow(
                condition: sorted[i],
                onTap: () => _onEditTap(context, sorted[i]),
              ),
            ],
        ],
      ),
    );
  }
}

class _PalierRow extends StatelessWidget {
  final Condition condition;
  final VoidCallback onTap;

  const _PalierRow({required this.condition, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = condition.days ?? 0;
    final montant = (condition.montant ?? 0).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'À partir de $days nuit${days > 1 ? 's' : ''}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${FcfaFormatter.compact(montant)} / nuit',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.text3,
            ),
          ],
        ),
      ),
    );
  }
}
