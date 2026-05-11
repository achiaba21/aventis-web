import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/capacity_edit_dialog.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/text_field_edit_dialog.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Infos » du `ProprioListingEditScreen`.
///
/// Consomme directement le modèle métier [Appartement] (`appartement`).
/// V9.1 (read) + V9.3 (write titre/type/description) + V9.4 (write
/// adresse/capacité). Tap sur n'importe quel champ ouvre le dialog dédié
/// et dispatch UpdateAppartement au save.
class ListingInfosTab extends StatelessWidget {
  final Appartement appartement;
  final Appartement? source;

  const ListingInfosTab({super.key, required this.appartement, this.source});

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
    final beds = source?.nbLits ?? appartement.bedsCount;
    final rooms = source?.nbChambres ?? 0;
    final baths = source?.nbDouches ?? appartement.bathsCount;
    return '${beds * 2} voyageurs · $rooms ch · $baths sdb';
  }

  String _addressText() {
    final addr = source?.address;
    final precise = addr?.nom?.trim();
    final commune = addr?.commune?.nom?.trim();
    final ville = addr?.commune?.ville?.nom?.trim();
    final parts = [
      if (precise != null && precise.isNotEmpty) precise,
      if (commune != null && commune.isNotEmpty) commune,
      if (ville != null && ville.isNotEmpty) ville,
    ];
    if (parts.isEmpty) return 'Adresse non précisée';
    return parts.join(', ');
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

  Future<void> _editAdresse(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final currentNom = source!.address?.nom;
    final commune = source!.address?.commune?.nom?.trim();
    final ville = source!.address?.commune?.ville?.nom?.trim();
    final localiteHint = [
      if (commune != null && commune.isNotEmpty) commune,
      if (ville != null && ville.isNotEmpty) ville,
    ].join(', ');
    final value = await TextFieldEditDialog.show(
      context,
      title: 'Modifier l\'adresse',
      subtitle: localiteHint.isEmpty
          ? 'Précisez la rue, le quartier ou un point de repère.'
          : 'Commune : $localiteHint (non modifiable). Précisez le numéro/rue ou un point de repère.',
      fieldLabel: 'ADRESSE PRÉCISE',
      initialValue: currentNom,
      hintText: 'Rue des Cocotiers, près du carrefour…',
      required: false,
    );
    if (value == null || value == (currentNom ?? '')) return;
    final newAddress = Address(
      id: source!.address?.id,
      lat: source!.address?.lat,
      longi: source!.address?.longi,
      geoLat: source!.address?.geoLat,
      geoLongi: source!.address?.geoLongi,
      nom: value.isEmpty ? null : value,
      commune: source!.address?.commune,
      description: source!.address?.description,
    );
    _dispatch(bloc, messenger, source!.copyWith(address: newAddress),
        'Adresse mise à jour');
  }

  Future<void> _editCapacity(BuildContext context) async {
    if (!_ensureEditable(context)) return;
    final bloc = context.read<AppartementBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await CapacityEditDialog.show(
      context,
      initialBeds: source!.nbLits ?? 0,
      initialRooms: source!.nbChambres ?? 0,
      initialBaths: source!.nbDouches ?? 0,
    );
    if (result == null) return;
    final unchanged = result.nbLits == source!.nbLits &&
        result.nbChambres == source!.nbChambres &&
        result.nbDouches == source!.nbDouches;
    if (unchanged) return;
    _dispatch(
      bloc,
      messenger,
      source!.copyWith(
        nbLits: result.nbLits,
        nbChambres: result.nbChambres,
        nbDouches: result.nbDouches,
      ),
      'Capacité mise à jour',
    );
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
            value: appartement.titleSafe,
            onTap: () => _editTitre(context),
          ),
          FieldRow(
            eyebrow: 'TYPE',
            value: _typeLabel(),
            onTap: () => _editType(context),
          ),
          FieldRow(
            eyebrow: 'ADRESSE',
            value: _addressText(),
            onTap: () => _editAdresse(context),
          ),
          FieldRow(
            eyebrow: 'CAPACITÉ',
            value: _capacityText(),
            onTap: () => _editCapacity(context),
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
