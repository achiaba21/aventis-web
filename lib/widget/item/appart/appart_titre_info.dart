import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget affichant le titre, la note et l'adresse d'un appartement
/// Utilisé dans les pages de détails (locataire et propriétaire)
class AppartTitreInfo extends StatelessWidget {
  const AppartTitreInfo(this.appart, {super.key});
  final Appartement appart;

  @override
  Widget build(BuildContext context) {
    final note = appart.note;
    final adresse = appart.address;
    final titre = appart.titre ?? "Appartement sans titre";
    final adresseDescription = adresse?.description ?? adresse?.nom ?? "Adresse non disponible";
    final nbChambres = appart.nbChambres ?? 0;
    final nbLits = appart.nbLits ?? 0;
    final nbDouches = appart.nbDouches ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre avec note
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextSeed(
                titre,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            Gap(Espacement.gapItem),
            // Badge note
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  Gap(4),
                  TextSeed(
                    note.toStringAsFixed(1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),

        Gap(Espacement.gapItem),

        // Adresse avec icône
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            Gap(6),
            Expanded(
              child: TextSeed(
                adresseDescription,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),

        Gap(Espacement.gapItem),

        // Informations rapides (chambres, lits, douches)
        Row(
          children: [
            _buildQuickInfo(Icons.bed_outlined, "$nbChambres chambres"),
            Gap(Espacement.gapSection),
            _buildQuickInfo(Icons.single_bed_outlined, "$nbLits lits"),
            Gap(Espacement.gapSection),
            _buildQuickInfo(Icons.shower_outlined, "$nbDouches douches"),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.background,
        ),
        Gap(4),
        TextSeed(
          label,
          fontSize: 13,
          color: AppColors.background,
        ),
      ],
    );
  }
}
