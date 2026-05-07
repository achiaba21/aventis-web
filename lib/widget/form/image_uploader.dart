import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/util/image_picker_util.dart';
import 'package:asfar/widget/form/photo_item_widget.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class UploadedImage {
  final String id;
  final String path;
  final String name;
  final double uploadProgress;
  final bool isUploading;
  final File? file; // Fichier image local

  const UploadedImage({
    required this.id,
    required this.path,
    required this.name,
    this.uploadProgress = 1.0,
    this.isUploading = false,
    this.file,
  });

  /// Créer une UploadedImage depuis un File
  factory UploadedImage.fromFile(File file, {String? id}) {
    final fileName = file.path.split('/').last;
    return UploadedImage(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      path: file.path,
      name: fileName,
      file: file,
      isUploading: false,
      uploadProgress: 1.0,
    );
  }
}

class ImageUploader extends StatelessWidget {
  const ImageUploader({
    super.key,
    required this.images,
    this.onImageAdd,
    required this.onImageRemove,
    this.existingPhotos = const [],
    this.onExistingPhotoRemove,
    this.maxImages = 10,
    this.imageQuality = 85,
  });

  final List<UploadedImage> images; // Nouvelles images locales
  final Function(File)? onImageAdd; // Callback avec le fichier sélectionné
  final Function(String) onImageRemove; // Callback pour retirer nouvelle image
  final List<PhotoAppart> existingPhotos; // Photos existantes (déjà sur serveur)
  final Function(String)? onExistingPhotoRemove; // Callback pour retirer photo existante
  final int maxImages; // Nombre maximum d'images
  final int imageQuality; // Qualité de l'image (0-100)

  @override
  Widget build(BuildContext context) {
    final totalImages = existingPhotos.length + images.length;

    return Column(
      children: [
        _buildUploadZone(context, totalImages),

        // Afficher les photos existantes (serveur)
        if (existingPhotos.isNotEmpty) ...[
          SizedBox(height: Espacement.gapSection),
          _buildExistingPhotosList(),
        ],

        // Afficher les nouvelles images locales
        if (images.isNotEmpty) ...[
          SizedBox(height: Espacement.gapSection),
          _buildImagesList(),
        ],
      ],
    );
  }

  Widget _buildUploadZone(BuildContext context, int totalImages) {
    return InkWell(
      onTap: () async {
        // Vérifier si le nombre maximum d'images est atteint
        if (totalImages >= maxImages) {
          return;
        }

        // Ouvrir le dialogue pour choisir l'image
        final File? selectedFile = await ImagePickerUtil.showImageSourceDialog(
          context: context,
          imageQuality: imageQuality,
        );

        // Si une image est sélectionnée, appeler le callback
        if (selectedFile != null && onImageAdd != null) {
          onImageAdd!(selectedFile);
        }
      },
      borderRadius: BorderRadius.circular(Espacement.radius),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textMuted,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(Espacement.radius),
          color: AppColors.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: Espacement.gapSection),
            TextSeed(
              "Upload images of your property",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            TextSeed(
              "from your device",
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingPhotosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          "Photos existantes",
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: Espacement.gapItem),
        ...existingPhotos.map((photo) => PhotoItemWidget(
          photoAppart: photo,
          subtitle: "Photo existante sur le serveur",
          isExisting: true,
          onRemove: onExistingPhotoRemove != null
              ? () => onExistingPhotoRemove!(photo.uuid!)
              : null,
        )),
      ],
    );
  }

  Widget _buildImagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          "Nouvelles images",
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: Espacement.gapItem),
        ...images.map((image) => PhotoItemWidget(
          localFile: image.file,
          title: image.name,
          isExisting: false,
          onRemove: () => onImageRemove(image.id),
        )),
      ],
    );
  }

}