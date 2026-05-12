import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/export/pdf/pdf_benefice_section.dart';
import 'package:asfar/service/export/pdf/pdf_header_section.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/pnl_aggregator.dart';

/// Orchestrateur de génération du rapport PDF Finances proprio.
///
/// Compose 4 pages :
/// - Page 1 : header + bénéfice net (livré dans cette phase)
/// - Page 2 : compte de résultat (P&L) — à venir
/// - Page 3 : performance par bien — à venir
/// - Page 4 : annexe détail réservations — à venir
class FinancesPdfExporter {
  FinancesPdfExporter._();

  /// Construit le PDF complet et retourne les bytes prêts à partager.
  static Future<Uint8List> build({
    required User proprio,
    required FinancePeriod period,
    required int year,
    required int index,
    required PnLBreakdown pnl,
    required int previousBeneficeAmount,
    required int beneficeDeltaPercent,
    required List<PropertyPerf> perfs,
    required List<Reservation> reservationsEncaissed,
    DateTime? generatedAt,
  }) async {
    final now = generatedAt ?? DateTime.now();
    final pdf = pw.Document(
      title: 'Asfar — Rapport Finances',
      author: proprio.fullName.trim().isNotEmpty
          ? proprio.fullName
          : 'Propriétaire',
      creator: 'Asfar Mobile',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: PdfTheme.pageMargin,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            PdfHeaderSection.build(
              proprio: proprio,
              period: period,
              year: year,
              index: index,
              generatedAt: now,
            ),
            pw.SizedBox(height: 18),
            PdfBeneficeSection.build(
              amount: pnl.netIncome.amount,
              previousAmount: previousBeneficeAmount,
              deltaPercent: beneficeDeltaPercent,
              pipelineAmount: pnl.pipelineRevenue,
              period: period,
              year: year,
              index: index,
            ),
            pw.SizedBox(height: 18),
            _placeholderForUpcomingSections(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _placeholderForUpcomingSections() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfTheme.bgSoft,
        border: pw.Border.all(color: PdfTheme.line, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        'Sections suivantes (compte de résultat, performance par bien, '
        'annexe réservations) — à venir dans les prochaines phases du PDF.',
        style: PdfTheme.muted(),
      ),
    );
  }
}
