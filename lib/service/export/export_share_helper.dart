import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:asfar/screen/client/proprio/comptabilite/pdf_preview_screen.dart';
import 'package:asfar/util/navigation.dart';

/// Helper de partage des exports Finances (PDF + CSV).
///
/// Le PDF est affiché dans un écran Flutter dédié (`PdfPreviewScreen`) avec
/// le widget `PdfPreview` du package `printing` qui propose scroll/zoom +
/// toolbar share/print intégrée. Évite le saut direct vers l'écran
/// d'impression de l'OS.
class ExportShareHelper {
  ExportShareHelper._();

  /// Pousse un écran d'aperçu PDF avec viewer intégré. L'utilisateur peut
  /// partager ou imprimer depuis la toolbar du viewer.
  static Future<void> previewPdf({
    required BuildContext context,
    required Uint8List bytes,
    required String fileName,
    String title = 'Aperçu',
  }) async {
    pushScreen(
      context,
      PdfPreviewScreen(bytes: bytes, fileName: fileName, title: title),
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
