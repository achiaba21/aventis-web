import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Section « Bénéfice net » du PDF Finances — sur la page 1 sous le header.
///
/// Affiche le bénéfice principal en gros, le delta vs période précédente,
/// le pipeline engagé si présent. Pas de gradient (print-friendly).
class PdfBeneficeSection {
  PdfBeneficeSection._();

  static pw.Widget build({
    required int amount,
    required int previousAmount,
    required int deltaPercent,
    required int pipelineAmount,
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    final positive = deltaPercent > 0;
    final negative = deltaPercent < 0;
    final deltaColor = positive
        ? PdfTheme.success
        : (negative ? PdfTheme.danger : PdfTheme.text3);
    final deltaBg = positive
        ? PdfTheme.successSoft
        : (negative ? PdfTheme.dangerSoft : PdfTheme.neutralSoft);
    final sign = positive ? '+' : (negative ? '-' : '');
    final prevLabel = period.previousPeriodLongLabel(year, index);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfTheme.bgSoft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfTheme.line, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BÉNÉFICE NET · ${period.periodLabel(year, index).toUpperCase()}',
            style: PdfTheme.eyebrow(),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            FcfaFormatter.full(amount),
            style: PdfTheme.monoBold(size: 28),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: deltaBg,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  '$sign${deltaPercent.abs()}%',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: deltaColor,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'vs. ${prevLabel.toLowerCase()} · ${FcfaFormatter.compact(previousAmount)}',
                style: PdfTheme.muted(),
              ),
            ],
          ),
          if (pipelineAmount > 0) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: 5,
                  height: 5,
                  decoration: const pw.BoxDecoration(
                    color: PdfTheme.accent,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Text(
                  'Engagé · ${FcfaFormatter.compact(pipelineAmount)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
