import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/container/dashed_border_container.dart';

/// Card CTA « Nouvelle annonce » dashed — bottom du `ProprioListingsScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListings`
/// (lignes 432-444) : `borderStyle: dashed, borderWidth: 1.5`, padding 24,
/// cercle 50×50 fond `accentSoft` + icon plus 22 accent, label 14px w600,
/// sub small 12px.
///
/// Tap = SnackBar « Création d'annonce disponible prochainement (F2) ».
class NewListingCard extends StatelessWidget {
  final VoidCallback? onTap;

  const NewListingCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: const DashedBorderContainer(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _PlusBadge(),
                SizedBox(height: 10),
                Text(
                  'Nouvelle annonce',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mettez votre logement en location en 5 min',
                  style: TextStyle(fontSize: 12, color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusBadge extends StatelessWidget {
  const _PlusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
      ),
      child: const Icon(Icons.add, size: 22, color: AppColors.accent),
    );
  }
}
