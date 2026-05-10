import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/text_field_edit_dialog.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Règles » du `ProprioListingEditScreen`.
///
/// V9.1 (read) : affichage du texte libre Appartement.regles.
/// V9.3 (write) : tap sur la card ou CTA EmptyState ouvre
/// TextFieldEditDialog (multiline) et dispatch UpdateAppartement au save.
class ListingRulesTab extends StatelessWidget {
  final Appartement? source;

  const ListingRulesTab({super.key, this.source});

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editRegles(BuildContext context) async {
    if (source == null) {
      _toast(context,
          'Annonce non chargée — réessayez quand les données sont prêtes.');
      return;
    }
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final value = await TextFieldEditDialog.show(
      context,
      title: 'Règles du logement',
      subtitle:
          'Arrivée, départ, animaux, fêtes, fumeurs, caution… Soyez clair pour éviter les malentendus.',
      fieldLabel: 'RÈGLES',
      initialValue: source!.regles,
      hintText:
          'Arrivée à partir de 14 h, départ avant 11 h. Pas d\'animaux, pas de fêtes. Caution 50 000 FCFA.',
      maxLines: 8,
      required: false,
    );
    if (value == null || value == source!.regles) return;
    final updated = source!.copyWith(regles: value);
    bloc.add(UpdateAppartement(updated));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Règles mises à jour'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regles = source?.regles?.trim();
    if (regles == null || regles.isEmpty) {
      return EmptyState.inline(
        icon: Icons.rule_outlined,
        title: 'Aucune règle définie',
        body: 'Précisez les règles de votre logement (arrivée, animaux, fêtes…).',
        ctaLabel: 'Ajouter',
        onCtaTap: () => _editRegles(context),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          FieldRow(
            eyebrow: 'RÈGLES DU LOGEMENT',
            value: regles,
            onTap: () => _editRegles(context),
          ),
        ],
      ),
    );
  }
}
