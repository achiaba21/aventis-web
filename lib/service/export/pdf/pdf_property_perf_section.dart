import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Section « Performance par bien » du PDF Finances — page 3.
///
/// Tableau filtré (seuls les biens avec revenus > 0 OU occupation > 0).
/// Colonnes : Bien (titre + commune) · Occupation % · Revenu net · Δ%.
/// Affiche un message d'état vide si aucun bien actif sur la période.
class PdfPropertyPerfSection {
  PdfPropertyPerfSection._();

  static pw.Widget build({required List<PropertyPerf> perfs}) {
    final activePerfs = perfs
        .where((p) => p.monthlyRevenue > 0 || p.occupancyRate > 0)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Performance par bien', style: PdfTheme.h1()),
        pw.SizedBox(height: 14),
        if (activePerfs.isEmpty)
          _emptyState()
        else
          _table(activePerfs),
      ],
    );
  }

  static pw.Widget _emptyState() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfTheme.bgSoft,
        border: pw.Border.all(color: PdfTheme.line, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Center(
        child: pw.Text(
          'Aucun bien actif sur cette période.',
          style: PdfTheme.muted(),
        ),
      ),
    );
  }

  static pw.Widget _table(List<PropertyPerf> perfs) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfTheme.line, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(2.5),
          1: pw.FlexColumnWidth(1.2),
          2: pw.FlexColumnWidth(1.6),
          3: pw.FlexColumnWidth(1.0),
        },
        children: [
          _headerRow(),
          for (final p in perfs) _dataRow(p),
        ],
      ),
    );
  }

  static pw.TableRow _headerRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfTheme.bgSoft),
      children: [
        _headerCell('BIEN'),
        _headerCell('OCCUPATION', align: pw.TextAlign.right),
        _headerCell('REVENU NET', align: pw.TextAlign.right),
        _headerCell('Δ%', align: pw.TextAlign.right),
      ],
    );
  }

  static pw.TableRow _dataRow(PropertyPerf p) {
    final occupancyPct = (p.occupancyRate * 100).round();
    final positive = p.deltaPercent > 0;
    final negative = p.deltaPercent < 0;
    final deltaColor = positive
        ? PdfTheme.success
        : (negative ? PdfTheme.danger : PdfTheme.text3);
    final sign = positive ? '+' : (negative ? '-' : '');

    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfTheme.line, width: 0.5),
        ),
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                p.appartement.titleSafe,
                style: PdfTheme.body().copyWith(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (p.appartement.areaName.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(p.appartement.areaName, style: PdfTheme.muted()),
              ],
            ],
          ),
        ),
        _alignedCell('$occupancyPct%'),
        _alignedCell(FcfaFormatter.full(p.monthlyRevenue), mono: true),
        _alignedCell('$sign${p.deltaPercent.abs()}%',
            color: deltaColor, bold: true),
      ],
    );
  }

  static pw.Widget _headerCell(String text, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: PdfTheme.eyebrow(),
      ),
    );
  }

  static pw.Widget _alignedCell(String text,
      {bool mono = false, bool bold = false, PdfColor? color}) {
    final base = mono
        ? PdfTheme.mono(size: 11, color: color)
        : PdfTheme.body().copyWith(color: color);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: bold
            ? base.copyWith(fontWeight: pw.FontWeight.bold)
            : base,
      ),
    );
  }
}
