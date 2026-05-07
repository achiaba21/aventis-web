import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/util/formate.dart';

/// Service pour générer les PDF des reçus style Asfar
class ReceiptPdfService {
  // Singleton
  static final ReceiptPdfService _instance = ReceiptPdfService._internal();
  factory ReceiptPdfService() => _instance;
  ReceiptPdfService._internal();

  /// Couleurs Asfar
  static const PdfColor _backgroundColor = PdfColor.fromInt(0xFF1E1E1E);
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFFFF6B35);
  static const PdfColor _whiteColor = PdfColors.white;
  static const PdfColor _greyColor = PdfColor.fromInt(0xFF9E9E9E);
  static const PdfColor _lightGreyColor = PdfColor.fromInt(0xFFBDBDBD);

  /// Génère le PDF d'un reçu style Asfar
  Future<pw.Document> generateReceiptPdf(Receipt receipt) async {
    final pdf = pw.Document();

    // Charger le logo (si disponible)
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/image/logo/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      // Logo non disponible, on continue sans
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: _backgroundColor,
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header avec logo
                _buildHeader(logoImage),
                pw.SizedBox(height: 40),

                // Titre principal
                _buildTitle(receipt),
                pw.SizedBox(height: 20),

                // Message d'introduction
                _buildIntroMessage(),
                pw.SizedBox(height: 30),

                // Contenu principal
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Nom du client
                      _buildClientSection(receipt),
                      pw.SizedBox(height: 24),

                      // Durée et dates
                      _buildDatesSection(receipt),
                      pw.SizedBox(height: 24),

                      // Localisation
                      _buildLocationSection(receipt),
                      pw.SizedBox(height: 24),

                      // Détails financiers
                      _buildFinancialSection(receipt),
                    ],
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Header avec logo Asfar
  pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            // Icône A stylisée
            pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                color: _primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  'A',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: _whiteColor,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Text(
              'Asfar',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: _whiteColor,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          "Explorez l'authenticité, comme chez vous.",
          style: pw.TextStyle(
            fontSize: 12,
            color: _greyColor,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Titre principal (type de reçu + date)
  pw.Widget _buildTitle(Receipt receipt) {
    final isDefinitif = receipt.typeRecu == ReceiptType.definitif;
    final typeLabel = isDefinitif ? 'Paiement complet' : 'Acompte payé';
    final dateStr = receipt.dateEmission != null
        ? _formatDate(receipt.dateEmission!)
        : '';

    return pw.Center(
      child: pw.Text(
        '$typeLabel - $dateStr',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
          color: _whiteColor,
        ),
      ),
    );
  }

  /// Message d'introduction
  pw.Widget _buildIntroMessage() {
    return pw.Center(
      child: pw.Text(
        'Cher client Asfar, merci de trouver ci-dessous le détail de la\nréservation de votre séjour :',
        style: pw.TextStyle(
          fontSize: 14,
          color: _greyColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Section client avec icône
  pw.Widget _buildClientSection(Receipt receipt) {
    return _buildIconRow(
      icon: _buildPersonIcon(),
      content: pw.Text(
        receipt.locataireFullName.isNotEmpty
            ? receipt.locataireFullName
            : 'Client',
        style: pw.TextStyle(
          fontSize: 16,
          color: _whiteColor,
        ),
      ),
    );
  }

  /// Section dates avec icône calendrier
  pw.Widget _buildDatesSection(Receipt receipt) {
    final nombreJours = receipt.nombreJours ?? 0;
    final dureeLabel = nombreJours > 1 ? '$nombreJours jours' : '$nombreJours jour';

    return _buildIconRow(
      icon: _buildCalendarIcon(),
      content: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            dureeLabel,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _whiteColor,
            ),
          ),
          pw.SizedBox(height: 8),
          if (receipt.dateDebut != null)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Check-in : ',
                    style: pw.TextStyle(fontSize: 13, color: _greyColor),
                  ),
                  pw.TextSpan(
                    text: _formatDateWithDay(receipt.dateDebut!),
                    style: pw.TextStyle(fontSize: 13, color: _whiteColor),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 4),
          if (receipt.dateFin != null)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Check-out : ',
                    style: pw.TextStyle(fontSize: 13, color: _greyColor),
                  ),
                  pw.TextSpan(
                    text: _formatDateWithDay(receipt.dateFin!),
                    style: pw.TextStyle(fontSize: 13, color: _whiteColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Section localisation
  pw.Widget _buildLocationSection(Receipt receipt) {
    final location = receipt.residenceNom ?? receipt.appartementTitre ?? '';
    if (location.isEmpty) return pw.SizedBox.shrink();

    return _buildIconRow(
      icon: _buildLocationIcon(),
      content: pw.Text(
        location,
        style: pw.TextStyle(
          fontSize: 14,
          color: _whiteColor,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  /// Section financière
  pw.Widget _buildFinancialSection(Receipt receipt) {
    final devise = receipt.devise ?? 'FCFA';
    final montantTotal = receipt.montantTotal ?? 0;
    final montantVerse = receipt.montantVerse ?? 0;
    final montantRestant = receipt.montantRestant ?? 0;
    final nombreJours = receipt.nombreJours ?? 1;

    // Calcul du prix par jour si possible
    final prixParJour = nombreJours > 0 ? (montantTotal / nombreJours).round() : 0;

    // Calcul du pourcentage d'acompte
    final pourcentageVerse = montantTotal > 0
        ? ((montantVerse / montantTotal) * 100).round()
        : 0;

    return _buildIconRow(
      icon: _buildMoneyIcon(),
      content: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Montant initial (prix x jours)
          if (prixParJour > 0)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Montant initial : ',
                    style: pw.TextStyle(fontSize: 13, color: _greyColor),
                  ),
                  pw.TextSpan(
                    text: '${helpAmountFormate(prixParJour, decim: false)} x $nombreJours = ${helpAmountFormate(montantTotal.toInt(), decim: false)} $devise',
                    style: pw.TextStyle(fontSize: 13, color: _whiteColor),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 6),

          // Montant du séjour
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Montant du séjour : ',
                  style: pw.TextStyle(fontSize: 13, color: _greyColor),
                ),
                pw.TextSpan(
                  text: '${helpAmountFormate(montantTotal.toInt(), decim: false)} $devise',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _whiteColor,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),

          // Acompte réglé
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Acompte réglé : ',
                  style: pw.TextStyle(fontSize: 13, color: _greyColor),
                ),
                pw.TextSpan(
                  text: '$pourcentageVerse% soit ${helpAmountFormate(montantVerse.toInt(), decim: false)} $devise',
                  style: pw.TextStyle(fontSize: 13, color: _primaryColor),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),

          // Réliquat (si > 0)
          if (montantRestant > 0)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Réliquat : ',
                    style: pw.TextStyle(fontSize: 13, color: _greyColor),
                  ),
                  pw.TextSpan(
                    text: '${helpAmountFormate(montantRestant.toInt(), decim: false)} $devise',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _whiteColor,
                    ),
                  ),
                ],
              ),
            ),

          // Moyen de paiement
          if (receipt.moyenPaiement != null) ...[
            pw.SizedBox(height: 6),
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Moyen de paiement : ',
                    style: pw.TextStyle(fontSize: 13, color: _greyColor),
                  ),
                  pw.TextSpan(
                    text: receipt.moyenPaiement!,
                    style: pw.TextStyle(fontSize: 13, color: _whiteColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Footer avec remerciements
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 30),
        pw.Center(
          child: pw.Text(
            'Merci pour ta confiance et à très bientôt...',
            style: pw.TextStyle(
              fontSize: 14,
              color: _whiteColor,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            "En cas de besoin, n'hésitez pas à nous contacter au +225 07 029 254 50",
            style: pw.TextStyle(
              fontSize: 12,
              color: _greyColor,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Team Asfar,',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: _lightGreyColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Ligne avec icône
  pw.Widget _buildIconRow({
    required pw.Widget icon,
    required pw.Widget content,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        icon,
        pw.SizedBox(width: 16),
        pw.Expanded(child: content),
      ],
    );
  }

  /// Icône personne (SVG-like)
  pw.Widget _buildPersonIcon() {
    return pw.Container(
      width: 24,
      height: 24,
      child: pw.CustomPaint(
        size: const PdfPoint(24, 24),
        painter: (canvas, size) {
          // Tête
          canvas.drawEllipse(12, 7, 5, 5);
          canvas.setStrokeColor(_greyColor);
          canvas.setLineWidth(1.5);
          canvas.strokePath();

          // Corps
          canvas.moveTo(4, 22);
          canvas.curveTo(4, 15, 8, 13, 12, 13);
          canvas.curveTo(16, 13, 20, 15, 20, 22);
          canvas.strokePath();
        },
      ),
    );
  }

  /// Icône calendrier
  pw.Widget _buildCalendarIcon() {
    return pw.Container(
      width: 24,
      height: 24,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _greyColor, width: 1.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            height: 6,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _greyColor, width: 1)),
            ),
          ),
          pw.Expanded(
            child: pw.GridView(
              crossAxisCount: 3,
              children: List.generate(
                6,
                (_) => pw.Container(
                  margin: const pw.EdgeInsets.all(1),
                  decoration: pw.BoxDecoration(
                    color: _greyColor.shade(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Icône localisation
  pw.Widget _buildLocationIcon() {
    return pw.Container(
      width: 24,
      height: 24,
      child: pw.Center(
        child: pw.Text(
          '📍',
          style: const pw.TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// Icône argent/reçu
  pw.Widget _buildMoneyIcon() {
    return pw.Container(
      width: 24,
      height: 24,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _greyColor, width: 1.5),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Center(
        child: pw.Text(
          '\$',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _greyColor,
          ),
        ),
      ),
    );
  }

  /// Partager le PDF
  Future<void> sharePdf(Receipt receipt) async {
    final pdf = await generateReceiptPdf(receipt);
    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: _getFileName(receipt),
    );
  }

  /// Sauvegarder le PDF
  Future<String> savePdf(Receipt receipt) async {
    final pdf = await generateReceiptPdf(receipt);
    final bytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileName(receipt);
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes);

    return file.path;
  }

  /// Imprimer le PDF
  Future<void> printPdf(Receipt receipt) async {
    final pdf = await generateReceiptPdf(receipt);
    final bytes = await pdf.save();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: _getFileName(receipt),
    );
  }

  /// Nom du fichier PDF
  String _getFileName(Receipt receipt) {
    final type = receipt.typeRecu == ReceiptType.definitif ? 'complet' : 'acompte';
    final numero = receipt.numeroRecu?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'recu';
    return 'recu_asfar_${type}_$numero.pdf';
  }

  /// Formater une date (JJ/MM/AAAA)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formater une date avec le jour de la semaine
  String _formatDateWithDay(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final dayName = days[date.weekday - 1];
    return '$dayName ${_formatDate(date)} à 12h';
  }
}
