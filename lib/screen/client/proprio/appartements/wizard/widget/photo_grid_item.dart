import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Item d'une photo dans la grille upload de l'étape 3 wizard.
///
/// Affiche l'image (depuis path local si dispo, sinon ImgPh tonal) avec
/// optionnellement un badge "Couverture" en overlay corner top-left et un
/// bouton supprimer top-right.
class PhotoGridItem extends StatelessWidget {
  final String? localPath;
  final int tone;
  final bool isCover;
  final VoidCallback? onRemove;

  const PhotoGridItem({
    super.key,
    required this.localPath,
    required this.tone,
    this.isCover = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _PhotoBackground(localPath: localPath, tone: tone),
            if (isCover) const _CoverBadge(),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: _RemoveButton(onTap: onRemove!),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoBackground extends StatelessWidget {
  final String? localPath;
  final int tone;

  const _PhotoBackground({required this.localPath, required this.tone});

  @override
  Widget build(BuildContext context) {
    final path = localPath;
    if (path != null && path.isNotEmpty) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            ImgPh(tone: tone, radius: AppRadii.sm),
      );
    }
    return ImgPh(tone: tone, radius: AppRadii.sm);
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Text(
          'Couverture',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.onAccent,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
