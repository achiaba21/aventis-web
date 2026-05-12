import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/calc/finance_period.dart';

/// Section header du PDF Finances — première chose visible sur la page 1.
///
/// Contient : logo placeholder ASFAR, titre « Rapport Finances »,
/// identité proprio (nom + telephone + email), période couverte,
/// date d'édition.
class PdfHeaderSection {
  PdfHeaderSection._();

  static pw.Widget build({
    required User proprio,
    required FinancePeriod period,
    required int year,
    required int index,
    required DateTime generatedAt,
  }) {
    final periodLong = period.longLabel(year, index);
    final genDate =
        '${generatedAt.day.toString().padLeft(2, '0')}/${generatedAt.month.toString().padLeft(2, '0')}/${generatedAt.year} '
        'à ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 18),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfTheme.line, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Brand
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'ASFAR',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfTheme.accent,
                  letterSpacing: 4,
                ),
              ),
              pw.Text(
                'Édité le $genDate',
                style: PdfTheme.muted(),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          // Title
          pw.Text('Rapport Finances', style: PdfTheme.title()),
          pw.SizedBox(height: 4),
          pw.Text(
            'Période · $periodLong',
            style: PdfTheme.body().copyWith(
              fontSize: 12,
              color: PdfTheme.text2,
            ),
          ),
          pw.SizedBox(height: 16),
          // Identité proprio en 2 colonnes
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _identityBlock(
                  label: 'PROPRIÉTAIRE',
                  primary: proprio.fullName.trim().isNotEmpty
                      ? proprio.fullName
                      : '—',
                  secondary: proprio.telephone ?? '—',
                ),
              ),
              pw.Expanded(
                child: _identityBlock(
                  label: 'CONTACT',
                  primary: proprio.email ?? '—',
                  secondary: proprio.telephone ?? '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _identityBlock({
    required String label,
    required String primary,
    required String secondary,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: PdfTheme.eyebrow()),
        pw.SizedBox(height: 4),
        pw.Text(primary, style: PdfTheme.body()),
        if (secondary.isNotEmpty && secondary != primary) ...[
          pw.SizedBox(height: 2),
          pw.Text(secondary, style: PdfTheme.muted()),
        ],
      ],
    );
  }
}
