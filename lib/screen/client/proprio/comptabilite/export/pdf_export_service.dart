import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/util/formate.dart';

/// Données nécessaires pour générer un rapport PDF
class PdfReportData {
  final String? residenceNom;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double chiffreAffaires;
  final double totalCharges;
  final double beneficeNet;
  final double margePourcent;
  final double tauxOccupation;
  final double prixMoyenAppartements;
  final int nombreReservations;
  final List<Charge> charges;

  PdfReportData({
    this.residenceNom,
    required this.dateDebut,
    required this.dateFin,
    required this.chiffreAffaires,
    required this.totalCharges,
    required this.beneficeNet,
    required this.margePourcent,
    required this.tauxOccupation,
    required this.prixMoyenAppartements,
    required this.nombreReservations,
    required this.charges,
  });

  bool get estBeneficiaire => beneficeNet > 0;
}

/// Service pour générer et exporter les rapports PDF de comptabilité
class PdfExportService {
  /// Génère et partage un rapport PDF
  static Future<void> generateAndShare(PdfReportData data) async {
    final pdf = await _generatePdf(data);

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: _generateFilename(data),
    );
  }

  /// Génère et affiche l'aperçu pour impression
  static Future<void> generateAndPrint(PdfReportData data) async {
    final pdf = await _generatePdf(data);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: _generateFilename(data),
    );
  }

  static String _generateFilename(PdfReportData data) {
    final dateDebut = DateFormat('MMM_yyyy', 'fr_FR').format(data.dateDebut);
    final residenceName = data.residenceNom?.replaceAll(' ', '_') ?? 'Toutes';
    return 'Rapport_${residenceName}_$dateDebut.pdf';
  }

  static Future<pw.Document> _generatePdf(PdfReportData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(data),
        footer: (context) => _buildFooter(context),
        build:
            (context) => [
              _buildSummarySection(data),
              pw.SizedBox(height: 20),
              _buildChargesSection(data.charges),
              pw.SizedBox(height: 20),
              _buildRepartitionSection(data),
            ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(PdfReportData data) {
    final periode = formatPeriodeFull(data.dateDebut, data.dateFin);

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RAPPORT COMPTABLE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                data.residenceNom ?? 'Toutes les résidences',
                style: const pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                periode,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Généré le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }

  static pw.Widget _buildSummarySection(PdfReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RÉSUMÉ FINANCIER',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricBox(
                'Chiffre d\'affaires',
                formatMontant(data.chiffreAffaires),
                PdfColors.green700,
              ),
              _buildMetricBox(
                'Total charges',
                formatMontant(data.totalCharges),
                PdfColors.red700,
              ),
              _buildMetricBox(
                data.estBeneficiaire ? 'Bénéfice net' : 'Déficit',
                formatMontant(data.beneficeNet.abs()),
                data.estBeneficiaire ? PdfColors.green900 : PdfColors.red900,
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Réservations', '${data.nombreReservations}'),
              _buildStatItem(
                'Taux d\'occupation',
                '${data.tauxOccupation.toStringAsFixed(1)}%',
              ),
              _buildStatItem(
                'Marge',
                '${data.margePourcent.toStringAsFixed(1)}%',
              ),
              _buildStatItem(
                'Prix moy. appart.',
                formatMontant(data.prixMoyenAppartements),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetricBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
        ),
      ],
    );
  }

  static pw.Widget _buildChargesSection(List<Charge> charges) {
    if (charges.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Text(
          'Aucune charge enregistrée pour cette période',
          style: const pw.TextStyle(color: PdfColors.grey500),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DÉTAIL DES CHARGES',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Libellé', isHeader: true),
                _buildTableCell('Type', isHeader: true),
                _buildTableCell('Montant', isHeader: true, alignRight: true),
                _buildTableCell('Statut', isHeader: true),
              ],
            ),
            // Data rows
            ...charges.map(
              (charge) => pw.TableRow(
                children: [
                  _buildTableCell(charge.labelComplet),
                  _buildTableCell(charge.frequence.label),
                  _buildTableCell(
                    formatMontant(charge.montant ?? 0),
                    alignRight: true,
                  ),
                  _buildTableCell(
                    charge.estPaye == true ? 'Payé' : 'À payer',
                    color:
                        charge.estPaye == true
                            ? PdfColors.green700
                            : PdfColors.orange700,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total: ${formatMontant(charges.fold<double>(0.0, (sum, c) => sum + (c.montant ?? 0)))}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool alignRight = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment:
          alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.grey800 : PdfColors.black),
        ),
      ),
    );
  }

  static pw.Widget _buildRepartitionSection(PdfReportData data) {
    final repartition = ComptabiliteCalculator.repartitionParType(data.charges);
    if (repartition.isEmpty || data.totalCharges == 0) return pw.Container();

    final sortedEntries =
        repartition.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RÉPARTITION DES CHARGES',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        ...sortedEntries.map((entry) {
          final percent = (entry.value / data.totalCharges * 100)
              .toStringAsFixed(1);
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    entry.key.label,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        height: 12,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.Container(
                        height: 12,
                        width: (entry.value / data.totalCharges) * 200,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue400,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    '${formatMontant(entry.value)} ($percent%)',
                    style: const pw.TextStyle(fontSize: 9),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
