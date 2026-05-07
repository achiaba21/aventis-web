import 'dart:io';

import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Aperçu de l'annonce comme la verra le locataire.
///
/// Réutilisé en étape 5 du wizard. Affiche photo de couverture, titre,
/// adresse résumée et statistiques de capacité.
class AppartementPreviewCard extends StatelessWidget {
  const AppartementPreviewCard({
    super.key,
    required this.appartement,
  });

  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Espacement.radius),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewCover(appartement: appartement),
          Padding(
            padding: EdgeInsets.all(Espacement.paddingBloc),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  appartement.titre?.trim().isNotEmpty == true
                      ? appartement.titre!
                      : "Sans titre",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: Espacement.gapItem),
                _PreviewLocation(appartement: appartement),
                SizedBox(height: Espacement.gapSection),
                _PreviewStats(appartement: appartement),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCover extends StatelessWidget {
  const _PreviewCover({required this.appartement});

  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    final firstPhoto = appartement.photos?.isNotEmpty == true
        ? appartement.photos!.first
        : null;
    final hasLocalFile = firstPhoto?.path != null && firstPhoto!.path!.isNotEmpty;

    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: hasLocalFile
          ? _CoverImage(path: firstPhoto.path!)
          : Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, width: double.infinity);
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _PreviewLocation extends StatelessWidget {
  const _PreviewLocation({required this.appartement});

  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    final addr = appartement.address;
    final label = addr?.commune?.nom ?? addr?.nom ?? "Adresse non renseignée";
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: AppColors.accent),
        SizedBox(width: Espacement.gapItem),
        Expanded(
          child: TextSeed(
            label,
            fontSize: 13,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PreviewStats extends StatelessWidget {
  const _PreviewStats({required this.appartement});

  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.bed_outlined,
          value: "${appartement.nbChambres ?? 0} ch",
        ),
        SizedBox(width: Espacement.gapSection),
        _StatItem(
          icon: Icons.single_bed_outlined,
          value: "${appartement.nbLits ?? 0} lits",
        ),
        SizedBox(width: Espacement.gapSection),
        _StatItem(
          icon: Icons.bathroom_outlined,
          value: "${appartement.nbDouches ?? 0} sdb",
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: Espacement.gapItem),
        TextSeed(
          value,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
