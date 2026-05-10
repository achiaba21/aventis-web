import 'dart:io';

/// Modèle data : une image uploadée par l'utilisateur dans un formulaire.
///
/// Précédemment défini dans `widget/form/image_uploader.dart` (couplage UI ↔
/// données). Extrait dans le layer model pour que les BLoCs/services puissent
/// le manipuler sans dépendre du widget.
class UploadedImage {
  final String id;
  final String path;
  final String name;
  final double uploadProgress;
  final bool isUploading;
  final File? file;

  const UploadedImage({
    required this.id,
    required this.path,
    required this.name,
    this.uploadProgress = 1.0,
    this.isUploading = false,
    this.file,
  });

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
