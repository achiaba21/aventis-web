import 'dart:io';
import 'package:flutter/material.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/appartement_mapper_util.dart';
import 'package:asfar/widget/form/form_section.dart';
import 'package:asfar/widget/form/image_uploader.dart';

/// Section pour ajouter/gérer des images de l'espace
/// Supporte à la fois les nouvelles images et les photos existantes
class ImagesSection extends StatelessWidget {
  const ImagesSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
    required this.images,
    required this.onImagesChanged,
    this.existingPhotos = const [],
    this.onExistingPhotosChanged,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;
  final List<UploadedImage> images; // Nouvelles images locales
  final Function(List<UploadedImage>) onImagesChanged;
  final List<PhotoAppart> existingPhotos; // Photos déjà sur le serveur
  final Function(List<PhotoAppart>)? onExistingPhotosChanged;

  void _handleImageAdd(File file) {
    final newImage = UploadedImage.fromFile(file);
    final updatedImages = [...images, newImage];

    // Mettre à jour la liste locale
    onImagesChanged(updatedImages);

    // Convertir et mettre à jour l'appartement
    final photos = AppartementMapperUtil.uploadedImagesToPhotoApparts(updatedImages);
    final updated = appartement?.copyWith(photos: photos);
    if (updated != null) {
      onAppartementChanged(updated);
    }
  }

  void _handleImageRemove(String imageId) {
    final updatedImages = images.where((image) => image.id != imageId).toList();

    // Mettre à jour la liste locale
    onImagesChanged(updatedImages);

    // Convertir et mettre à jour l'appartement
    final photos = AppartementMapperUtil.uploadedImagesToPhotoApparts(updatedImages);
    final updated = appartement?.copyWith(photos: photos);
    if (updated != null) {
      onAppartementChanged(updated);
    }
  }

  void _handleExistingPhotoRemove(String photoUuid) {
    if (onExistingPhotosChanged == null) return;

    // Retirer la photo de la liste des photos existantes
    final updatedPhotos = existingPhotos.where((photo) => photo.uuid != photoUuid).toList();
    onExistingPhotosChanged!(updatedPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Ajouter des images de votre espace",
      child: ImageUploader(
        images: images,
        onImageAdd: _handleImageAdd,
        onImageRemove: _handleImageRemove,
        existingPhotos: existingPhotos,
        onExistingPhotoRemove: _handleExistingPhotoRemove,
      ),
    );
  }
}
