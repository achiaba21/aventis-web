import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/text_field_edit_dialog.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Infos » du `ProprioListingEditScreen`.
///
/// V9.1 (read) : description, type, capacité depuis Appartement réel.
/// V9.3 (write) : tap sur TITRE / TYPE / DESCRIPTION ouvre
/// `TextFieldEditDialog` et dispatch UpdateAppartement au save. ADRESSE
/// et CAPACITÉ restent stub (champs structurés à concevoir séparément).
class ListingInfosTab extends StatelessWidget {
  final ListingPreview listing;
  final Appartement? source;

  const ListingInfosTab({super.key, required this.listing, this.source});

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _typeLabel() {
    final t = source?.typeLocation?.trim();
    if (t == null || t.isEmpty) return 'Non précisé';
    return t;
  }

  String _descriptionText() {
    final d = source?.description?.trim();
    if (d == null || d.isEmpty) {
      return 'Aucune description renseignée';
    }
    return d;
  }

  String _capacityText() {
    final beds = source?.nbLits ?? listing.beds;
    final rooms = source?.nbChambres ?? 0;
    final baths = source?.nbDouches ?? listing.baths;
    return '${beds * 2} voyageurs · $rooms ch · $baths sdb';
  }

  bool _ensureEditable(BuildContext context) {
    if (source == null) {
      _toast(context,
          'Annonce non chargée — réessayez quand les données sont prêtes.');
      return false;
    }
    return true;
  }

  Future<void> _editTitre(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final value = await TextFieldEditDialog.show(
      context,
      title: 'Modifier le titre',
      subtitle: 'Titre court et descriptif de votre annonce.',
      fieldLabel: 'TITRE',
      initialValue: source!.titre,
      hintText: 'Loft moderne au Plateau',
    );
    if (value == null || value == source!.titre) return;
    _dispatch(bloc, messenger, source!.copyWith(titre: value),
        'Titre mis à jour');
  }

  Future<void> _editType(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final value = await TextFieldEditDialog.show(
      context,
      title: 'Modifier le type',
      subtitle: 'Ex : Appartement entier, Studio, Chambre privée…',
      fieldLabel: 'TYPE',
      initialValue: source!.typeLocation,
      hintText: 'Appartement entier',
    );
    if (value == null || value == source!.typeLocation) return;
    _dispatch(bloc, messenger, source!.copyWith(typeLocation: value),
        'Type mis à jour');
  }

  Future<void> _editDescription(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final value = await TextFieldEditDialog.show(
      context,
      title: 'Modifier la description',
      subtitle: 'Décrivez l\'ambiance, les points forts, le quartier.',
      fieldLabel: 'DESCRIPTION',
      initialValue: source!.description,
      hintText: 'Espace lumineux et calme au cœur de…',
      maxLines: 6,
      required: false,
    );
    if (value == null || value == source!.description) return;
    _dispatch(bloc, messenger, source!.copyWith(description: value),
        'Description mise à jour');
  }

  void _dispatch(
    AppartementBloc bloc,
    ScaffoldMessengerState messenger,
    Appartement updated,
    String successMessage,
  ) {
    bloc.add(UpdateAppartement(updated));
    messenger.showSnackBar(
      SnackBar(
        content: Text(successMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            eyebrow: 'TITRE',
            value: listing.title,
            onTap: () => _editTitre(context),
          ),
          FieldRow(
            eyebrow: 'TYPE',
            value: _typeLabel(),
            onTap: () => _editType(context),
          ),
          FieldRow(
            eyebrow: 'ADRESSE',
            value:
                '${listing.area}${listing.area.isNotEmpty && listing.city.isNotEmpty ? ', ' : ''}${listing.city}',
            onTap: () => _toast(context, 'Édition adresse en V9.4'),
          ),
          FieldRow(
            eyebrow: 'CAPACITÉ',
            value: _capacityText(),
            onTap: () => _toast(context, 'Édition capacité en V9.4'),
          ),
          FieldRow(
            eyebrow: 'DESCRIPTION',
            value: _descriptionText(),
            onTap: () => _editDescription(context),
          ),
        ],
      ),
    );
  }
}
