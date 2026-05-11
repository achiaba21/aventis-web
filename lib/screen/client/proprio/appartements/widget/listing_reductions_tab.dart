import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/base_price_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/reduction_palier_dialog.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Réductions » du `ProprioListingEditScreen`.
///
/// Consomme directement le modèle métier [Appartement] (`appartement`).
/// V9.1 (read) : affichage des paliers depuis Appartement.remises.conditions.
/// V9.2 (write) : tap sur un palier ouvre `ReductionPalierDialog` en édition,
/// tap sur EmptyState/CTA ouvre le dialog en création. Save/delete construit
/// un Appartement.copyWith(remises: ...) et dispatche UpdateAppartement.
class ListingReductionsTab extends StatelessWidget {
  final Appartement appartement;
  final Appartement? source;

  const ListingReductionsTab({
    super.key,
    required this.appartement,
    this.source,
  });

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Condition> _sortedConditions() {
    final c = source?.remises?.conditions;
    if (c == null) return const [];
    final list = List<Condition>.from(c)
      ..sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));
    return list;
  }

  String _seuilLabel(int? days) {
    if (days == null || days <= 0) return 'PALIER';
    return 'À PARTIR DE $days NUITS';
  }

  /// `Condition.montant` = nouveau prix journalier (FCFA) appliqué au-delà
  /// du seuil `days`. Affiché en format compact "/nuit" pour cohérence avec
  /// le tarif de base au-dessus.
  String _montantLabel(double? montant) {
    if (montant == null) return '—';
    return '${FcfaFormatter.full(montant.round())} / nuit';
  }

  Future<void> _onAddPalier(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await ReductionPalierDialog.show(context);
    if (result?.condition == null) return;
    _applyChange(
      bloc: bloc,
      messenger: messenger,
      addOrUpdate: result!.condition,
    );
  }

  Future<void> _onEditPalier(BuildContext context, Condition initial) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await ReductionPalierDialog.show(context, initial: initial);
    if (result == null) return;
    if (result.delete) {
      _applyChange(
        bloc: bloc,
        messenger: messenger,
        deleteId: initial.id,
        deleteFallback: initial,
      );
    } else if (result.condition != null) {
      _applyChange(
        bloc: bloc,
        messenger: messenger,
        addOrUpdate: result.condition,
      );
    }
  }

  bool _ensureEditable(BuildContext context) {
    if (source == null) {
      _toast(context,
          'Annonce non chargée — réessayez quand les données sont prêtes.');
      return false;
    }
    return true;
  }

  void _applyChange({
    required AppartementBloc bloc,
    required ScaffoldMessengerState messenger,
    Condition? addOrUpdate,
    int? deleteId,
    Condition? deleteFallback,
  }) {
    final appart = source!;
    final current = List<Condition>.from(appart.remises?.conditions ?? const []);

    if (deleteId != null) {
      current.removeWhere((c) => c.id == deleteId);
    } else if (deleteFallback != null) {
      // Fallback : palier sans id côté serveur, retrait par days/montant
      current.removeWhere(
        (c) =>
            c.days == deleteFallback.days &&
            c.montant == deleteFallback.montant,
      );
    }
    if (addOrUpdate != null) {
      final idx = addOrUpdate.id == null
          ? -1
          : current.indexWhere((c) => c.id == addOrUpdate.id);
      if (idx >= 0) {
        current[idx] = addOrUpdate;
      } else {
        current.add(addOrUpdate);
      }
    }

    final updatedRemise = Remise(
      id: appart.remises?.id,
      conditions: current,
    );
    final updatedAppart = appart.copyWith(remises: updatedRemise);
    bloc.add(UpdateAppartement(updatedAppart));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleteId != null || deleteFallback != null
              ? 'Palier supprimé'
              : (addOrUpdate?.id == null
                  ? 'Palier ajouté'
                  : 'Palier mis à jour'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = appartement.priceAmount;
    final conditions = _sortedConditions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BasePriceCard(basePrice: basePrice),
        const SizedBox(height: 14),
        if (conditions.isEmpty)
          EmptyState.inline(
            icon: Icons.local_offer_outlined,
            title: 'Aucune réduction configurée',
            body:
                'Ajoutez des paliers (ex : −10 % à partir de 7 nuits) pour attirer les séjours longs.',
            ctaLabel: 'Ajouter un palier',
            onCtaTap: () => _onAddPalier(context),
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Paliers de réductions',
                style: AppTextStyles.h3,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onAddPalier(context),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.accent),
                        SizedBox(width: 4),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final c in conditions)
                  FieldRow(
                    eyebrow: _seuilLabel(c.days),
                    value: _montantLabel(c.montant),
                    trailingIcon: Icons.chevron_right,
                    onTap: () => _onEditPalier(context, c),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
