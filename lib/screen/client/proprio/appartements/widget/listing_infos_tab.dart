import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Infos » du `ProprioListingEditScreen`.
///
/// Read-only branché sur l'`Appartement` source : description et type
/// affichés depuis les données réelles. Édition (write) en V9.
class ListingInfosTab extends StatelessWidget {
  final ListingPreview listing;
  final Appartement? source;

  const ListingInfosTab({super.key, required this.listing, this.source});

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible en V9'),
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
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'TYPE',
              value: _typeLabel(),
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'ADRESSE',
              value: '${listing.area}${listing.area.isNotEmpty && listing.city.isNotEmpty ? ', ' : ''}${listing.city}',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'CAPACITÉ',
              value: _capacityText(),
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'DESCRIPTION',
              value: _descriptionText(),
              onTap: () => _stub(context)),
        ],
      ),
    );
  }
}
