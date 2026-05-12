import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/calc/pnl_aggregator.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Section P&L du PDF Finances — page 2.
///
/// Reproduit le `PnLCard` de l'écran sous forme tabulaire :
/// - Section « + Revenus » : header + lignes détail (locations brutes + nuits)
/// - Section « − Charges » : header + lignes détail (frais Asfar,
///   commissions démarcheurs, charges variées)
/// - Total : Bénéfice net + Marge nette
/// - Note méthode en bas (statuts comptés, taux frais Asfar)
class PdfPnlSection {
  PdfPnlSection._();

  static pw.Widget build({required PnLBreakdown pnl}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Compte de résultat', style: PdfTheme.h1()),
        pw.SizedBox(height: 14),
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfTheme.line, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            children: [
              _categoryRow(pnl.revenueHeader, isHeader: true),
              for (final entry in pnl.revenueDetails) _categoryRow(entry),
              _divider(),
              _categoryRow(pnl.chargeHeader, isHeader: true),
              for (final entry in pnl.chargeDetails) _categoryRow(entry),
              _divider(emphasis: true),
              _totalRow(pnl.netIncome, large: true),
              _totalRow(pnl.netMargin, isPercent: true),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfTheme.bgSoft,
            border: pw.Border.all(color: PdfTheme.line, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MÉTHODE', style: PdfTheme.eyebrow()),
              pw.SizedBox(height: 4),
              pw.Text(
                '• Statuts comptés : PAYER + FINALISER + TERMINEE.\n'
                '• Statut CONFIRMER (engagement non payé) exclu — voir « Engagé ».\n'
                '• Frais plateforme Asfar : montant réel facturé par résa.\n'
                '• Commission démarcheur : montant réel par résa référée.',
                style: PdfTheme.muted(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _categoryRow(PnLEntry entry, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: isHeader
          ? const pw.BoxDecoration(color: PdfTheme.bgSoft)
          : null,
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              entry.label,
              style: isHeader
                  ? PdfTheme.h2().copyWith(fontSize: 12)
                  : PdfTheme.body(),
            ),
          ),
          pw.Text(
            FcfaFormatter.full(entry.amount),
            style: isHeader
                ? PdfTheme.monoBold(size: 13)
                : PdfTheme.mono(size: 11),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(PnLEntry entry,
      {bool large = false, bool isPercent = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: large ? PdfTheme.bgSoft : null,
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              entry.label,
              style: large ? PdfTheme.h2() : PdfTheme.body(),
            ),
          ),
          pw.Text(
            isPercent
                ? '${entry.amount}%'
                : FcfaFormatter.full(entry.amount),
            style: large
                ? PdfTheme.monoBold(size: 16, color: PdfTheme.accent)
                : PdfTheme.mono(size: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider({bool emphasis = false}) {
    return pw.Container(
      height: emphasis ? 1.5 : 0.5,
      color: PdfTheme.line,
    );
  }
}
