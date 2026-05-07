import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget réutilisable pour afficher une photo (serveur ou locale)
/// Affiche une miniature + informations + bouton supprimer
class PhotoItemWidget extends StatelessWidget {
  const PhotoItemWidget({
    super.key,
    this.photoAppart,
    this.localFile,
    this.title,
    this.subtitle,
    this.onRemove,
    this.isExisting = false,
  });

  final PhotoAppart? photoAppart; // Photo existante sur le serveur
  final File? localFile; // Image locale nouvellement ajoutée
  final String? title; // Titre à afficher
  final String? subtitle; // Sous-titre à afficher
  final VoidCallback? onRemove; // Callback pour supprimer
  final bool isExisting; // Indique si c'est une photo existante (pour le style)

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Espacement.gapSection / 2),
      padding: EdgeInsets.all(Espacement.paddingBloc / 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: isExisting ? AppColors.info : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Row(
        children: [
          _buildThumbnail(context),
          SizedBox(width: Espacement.gapSection),
          _buildInfo(),
          if (onRemove != null) _buildRemoveButton(),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePreview(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Si c'est une photo du serveur
    if (photoAppart != null && photoAppart!.path != null) {
      return ImageNet(
        photoAppart!.path,
        size: 50,
        radius: 8,
      );
    }

    // Si c'est un fichier local
    if (localFile != null) {
      return Image.file(
        localFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image, color: AppColors.textMuted);
        },
      );
    }

    // Aucune image disponible
    return Icon(Icons.image, color: AppColors.textMuted);
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            title ?? _getDefaultTitle(),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            TextSeed(
              subtitle!,
              fontSize: 12,
              color: isExisting ? AppColors.info : AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRemoveButton() {
    return IconButton(
      icon: Icon(Icons.delete_outline, color: AppColors.error),
      onPressed: onRemove,
      tooltip: "Supprimer cette photo",
    );
  }

  String _getDefaultTitle() {
    if (photoAppart != null) {
      return photoAppart!.titre ??
             "Image ${photoAppart!.uuid?.substring(0, 8) ?? ''}";
    }
    if (localFile != null) {
      return localFile!.path.split('/').last;
    }
    return "Image sans titre";
  }

  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.textPrimary,
      builder: (context) => _ImagePreviewDialog(
        photoAppart: photoAppart,
        localFile: localFile,
        title: title ?? _getDefaultTitle(),
      ),
    );
  }
}

/// Dialog interne pour la prévisualisation de l'image
class _ImagePreviewDialog extends StatelessWidget {
  const _ImagePreviewDialog({
    this.photoAppart,
    this.localFile,
    required this.title,
  });

  final PhotoAppart? photoAppart;
  final File? localFile;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(Espacement.paddingBloc),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec titre et bouton fermer
          Container(
            padding: EdgeInsets.all(Espacement.paddingBloc),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Espacement.radius * 2),
                topRight: Radius.circular(Espacement.radius * 2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextSeed(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.background),
                  onPressed: () => Navigator.pop(context),
                  tooltip: "Fermer",
                ),
              ],
            ),
          ),

          // Image en grand
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Espacement.radius * 2),
                bottomRight: Radius.circular(Espacement.radius * 2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Espacement.radius * 2),
                bottomRight: Radius.circular(Espacement.radius * 2),
              ),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildFullImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullImage() {
    // Si c'est une photo du serveur
    if (photoAppart != null && photoAppart!.path != null) {
      return ImageNet(
        photoAppart!.path,
        width: double.infinity,
        radius: 0,
      );
    }

    // Si c'est un fichier local
    if (localFile != null) {
      return Image.file(
        localFile!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: AppColors.textMuted),
                SizedBox(height: 8),
                TextSeed(
                  "Impossible de charger l'image",
                  color: AppColors.textMuted,
                ),
              ],
            ),
          );
        },
      );
    }

    // Aucune image disponible
    return Center(
      child: Icon(Icons.image, size: 64, color: AppColors.textMuted),
    );
  }
}
