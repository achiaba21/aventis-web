import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran d'aperçu d'un PDF généré (export Finances proprio).
///
/// Utilise `PdfPreview` du package `printing` pour un viewer intégré avec
/// scroll/zoom/pinch + toolbar partage et impression. Évite le saut direct
/// vers l'écran d'impression de l'OS (qui était le comportement de
/// `Printing.layoutPdf`).
class PdfPreviewScreen extends StatelessWidget {
  final Uint8List bytes;
  final String fileName;
  final String title;

  const PdfPreviewScreen({
    super.key,
    required this.bytes,
    required this.fileName,
    this.title = 'Aperçu',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: title,
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: PdfPreview(
        build: (_) async => bytes,
        pdfFileName: fileName,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowSharing: true,
        allowPrinting: true,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      ),
    );
  }
}
