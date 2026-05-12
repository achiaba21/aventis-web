import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/export/pdf/pdf_benefice_section.dart';
import 'package:asfar/service/export/pdf/pdf_header_section.dart';
import 'package:asfar/service/export/pdf/pdf_pnl_section.dart';
import 'package:asfar/service/export/pdf/pdf_property_perf_section.dart';
import 'package:asfar/service/export/pdf/pdf_reservations_section.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/pnl_aggregator.dart';

/// Orchestrateur de génération du rapport PDF Finances proprio.
///
/// Compose 3 pages A4 :
/// - Page 1 : header + bénéfice net hero + compte de résultat (P&L)
///   — `MultiPage` pour gérer le débordement si le P&L est long
/// - Page 2 : performance par bien
/// - Page 3 : annexe détail des réservations encaissées (MultiPage)
class FinancesPdfExporter {
  FinancesPdfExporter._();

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
    // Noto Sans (subset Google Fonts) : couvre Latin Extended + symboles
    // courants (•, —, ·, É, ç, Δ, ᵉ, «, »). Ne couvre PAS les flèches
    // Unicode (↑↓→) ni Mathematical Operators (−) — d'où l'usage de signes
    // ASCII (+/-) dans les sections P&L et perf par bien.
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final italic = await PdfGoogleFonts.notoSansItalic();
    final boldItalic = await PdfGoogleFonts.notoSansBoldItalic();

    final pdf = pw.Document(
      title: 'Asfar — Rapport Finances',
      author: proprio.fullName.trim().isNotEmpty
          ? proprio.fullName
          : 'Propriétaire',
      creator: 'Asfar Mobile',
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: italic,
        boldItalic: boldItalic,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: PdfTheme.pageMargin,
        build: (context) => [
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
          pw.SizedBox(height: 22),
          PdfPnlSection.build(pnl: pnl),
        ],
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: PdfTheme.pageMargin,
        build: (context) => PdfPropertyPerfSection.build(perfs: perfs),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: PdfTheme.pageMargin,
        build: (context) => [
          PdfReservationsSection.build(reservations: reservationsEncaissed),
        ],
      ),
    );

    return pdf.save();
  }
}
