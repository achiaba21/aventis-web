import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Infos » du `ProprioListingEditScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 522-531) : 6 `FieldRow` (Titre / Type / Adresse / Surface /
/// Capacité / Description) regroupés dans une seule Container card pour
/// cohérence avec le pattern V5 `LocataireReserveScreen`.
///
/// Chaque tap = SnackBar « Édition disponible prochainement ».
class ListingInfosTab extends StatelessWidget {
  final ListingPreview listing;

  const ListingInfosTab({super.key, required this.listing});

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible prochainement'),
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
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'TYPE',
              value: 'Appartement entier',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'ADRESSE',
              value: '${listing.area}, ${listing.city}',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'SURFACE',
              value: '${listing.surface} m²',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'CAPACITÉ',
              value:
                  '${listing.beds * 2} voyageurs · ${listing.beds} ch · ${listing.baths} sdb',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'DESCRIPTION',
              value: 'Espace lumineux et calme au cœur de…',
              onTap: () => _stub(context)),
        ],
      ),
    );
  }
}
