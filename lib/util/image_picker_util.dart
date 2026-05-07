import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';

/// Utilitaire pour sélectionner des images depuis la caméra ou la galerie
class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis une source spécifique (caméra ou galerie)
  ///
  /// Paramètres:
  /// - [source] : Source de l'image (ImageSource.camera ou ImageSource.gallery)
  /// - [maxWidth] : Largeur maximale de l'image (optionnel)
  /// - [maxHeight] : Hauteur maximale de l'image (optionnel)
  /// - [imageQuality] : Qualité de l'image 0-100 (optionnel, par défaut 85)
  ///
  /// Retourne:
  /// - [File?] : Le fichier image sélectionné ou null si annulé/erreur
  static Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        deboger("Image sélectionnée: ${pickedFile.path}");
        return File(pickedFile.path);
      }

      deboger("Sélection d'image annulée");
      return null;
    } catch (e) {
      deboger("Erreur lors de la sélection d'image: $e");
      return null;
    }
  }

  /// Sélectionne plusieurs images depuis la galerie
  ///
  /// Paramètres:
  /// - [maxImages] : Nombre maximum d'images (optionnel, par défaut 5)
  /// - [imageQuality] : Qualité des images 0-100 (optionnel, par défaut 85)
  ///
  /// Retourne:
  /// - [List<File>] : Liste des fichiers images sélectionnés (vide si annulé/erreur)
  static Future<List<File>> pickMultipleImages({
    int maxImages = 5,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
      );

      if (pickedFiles.isNotEmpty) {
        // Limiter au nombre maximum d'images
        final limitedFiles = pickedFiles.take(maxImages).toList();
        deboger("${limitedFiles.length} images sélectionnées");
        return limitedFiles.map((xFile) => File(xFile.path)).toList();
      }

      deboger("Sélection d'images annulée");
      return [];
    } catch (e) {
      deboger("Erreur lors de la sélection d'images: $e");
      return [];
    }
  }

  /// Affiche un dialogue pour choisir la source de l'image (caméra ou galerie)
  ///
  /// Paramètres:
  /// - [context] : BuildContext pour afficher le dialogue
  /// - [maxWidth] : Largeur maximale de l'image (optionnel)
  /// - [maxHeight] : Hauteur maximale de l'image (optionnel)
  /// - [imageQuality] : Qualité de l'image 0-100 (optionnel, par défaut 85)
  ///
  /// Retourne:
  /// - [File?] : Le fichier image sélectionné ou null si annulé
  static Future<File?> showImageSourceDialog({
    required BuildContext context,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                Text(
                  'Choisir une image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Option Caméra
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  title: Text(
                    'Prendre une photo',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    final file = await pickImage(
                      source: ImageSource.camera,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                const Divider(),

                // Option Galerie
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  title: Text(
                    'Choisir depuis la galerie',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    final file = await pickImage(
                      source: ImageSource.gallery,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                const SizedBox(height: 10),

                // Bouton Annuler
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.inactive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Affiche un dialogue pour choisir plusieurs images depuis la galerie
  ///
  /// Paramètres:
  /// - [context] : BuildContext pour afficher le dialogue
  /// - [maxImages] : Nombre maximum d'images (optionnel, par défaut 5)
  /// - [imageQuality] : Qualité des images 0-100 (optionnel, par défaut 85)
  ///
  /// Retourne:
  /// - [List<File>] : Liste des fichiers images sélectionnés (vide si annulé)
  static Future<List<File>> showMultipleImagesDialog({
    required BuildContext context,
    int maxImages = 5,
    int imageQuality = 85,
  }) async {
    final files = await pickMultipleImages(
      maxImages: maxImages,
      imageQuality: imageQuality,
    );
    return files;
  }

  /// Vérifie si la taille du fichier est acceptable
  ///
  /// Paramètres:
  /// - [file] : Fichier à vérifier
  /// - [maxSizeInMB] : Taille maximale en MB (par défaut 5MB)
  ///
  /// Retourne:
  /// - [bool] : true si la taille est acceptable, false sinon
  static Future<bool> checkFileSize(File file, {double maxSizeInMB = 5.0}) async {
    try {
      final fileSize = await file.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      deboger("Taille du fichier: ${fileSizeInMB.toStringAsFixed(2)} MB");

      return fileSizeInMB <= maxSizeInMB;
    } catch (e) {
      deboger("Erreur lors de la vérification de la taille: $e");
      return false;
    }
  }
}
