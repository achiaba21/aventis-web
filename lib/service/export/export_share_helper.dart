import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Helper de partage des exports Finances (PDF + CSV).
///
/// Wraps `printing` package pour proposer preview puis share. Le PDF est
/// d'abord affiché en plein écran via `Printing.layoutPdf` (preview natif
/// avec zoom, rotation, share, impression). L'utilisateur peut ensuite
/// partager via le bouton intégré.
class ExportShareHelper {
  ExportShareHelper._();

  /// Ouvre le preview PDF natif. L'utilisateur peut partager / imprimer
  /// depuis le viewer.
  static Future<void> previewPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: fileName,
    );
  }

  /// Partage direct (sans preview) du PDF.
  static Future<void> sharePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  /// Partage direct d'un CSV (texte) — encodé en UTF-8 BOM pour Excel.
  static Future<void> shareCsv({
    required String content,
    required String fileName,
  }) async {
    final bytes = Uint8List.fromList(
      [0xEF, 0xBB, 0xBF, ...content.codeUnits],
    );
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  /// Slugify une période pour le nom de fichier.
  /// Ex : `Asfar_Finances_2026-11_édité-2026-05-12.pdf`
  static String buildFileName({
    required String periodSlug,
    required DateTime generatedAt,
    required String extension,
  }) {
    final genDate =
        '${generatedAt.year}-${generatedAt.month.toString().padLeft(2, '0')}-${generatedAt.day.toString().padLeft(2, '0')}';
    return 'Asfar_Finances_${periodSlug}_édité-$genDate.$extension';
  }

  /// Affiche un SnackBar d'erreur générique pour l'export.
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
