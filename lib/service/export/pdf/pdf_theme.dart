import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Thème PDF Asfar — palette épurée print-friendly et fontes.
///
/// La palette PDF est volontairement différente de l'app : fond blanc,
/// texte noir, accent or pour les eyebrows et totaux. Pas de gradient,
/// pas de bgElev (inutile à l'impression).
///
/// Fontes : Helvetica par défaut. Une fonte mono custom peut être embeddée
/// via `loadMonoFont()` quand `assets/fonts/pdf/JetBrainsMono-Regular.ttf`
/// sera fourni. Pour l'instant, fallback sur Courier.
class PdfTheme {
  PdfTheme._();

  // Palette
  static const PdfColor accent = PdfColor.fromInt(0xFFE8B86B);
  static const PdfColor accentSoft = PdfColor.fromInt(0xFFFAF1DF);
  static const PdfColor text = PdfColor.fromInt(0xFF1A1A1F);
  static const PdfColor text2 = PdfColor.fromInt(0xFF555560);
  static const PdfColor text3 = PdfColor.fromInt(0xFF8A8A95);
  static const PdfColor line = PdfColor.fromInt(0xFFE5E5EA);
  static const PdfColor bgSoft = PdfColor.fromInt(0xFFFAFAFB);
  static const PdfColor success = PdfColor.fromInt(0xFF2E8B4D);
  static const PdfColor danger = PdfColor.fromInt(0xFFC0392B);

  /// Variantes pâles pour fond de pill/chip — contraste élevé avec le texte
  /// sémantique correspondant. Calculées comme blanc tinté ~10%.
  static const PdfColor successSoft = PdfColor.fromInt(0xFFE6F4EA);
  static const PdfColor dangerSoft = PdfColor.fromInt(0xFFFCE8E6);
  static const PdfColor neutralSoft = PdfColor.fromInt(0xFFEEEEF0);

  // Marges page A4
  static const pageMargin = pw.EdgeInsets.fromLTRB(40, 36, 40, 40);

  // Styles texte
  static pw.TextStyle title({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 22,
        fontWeight: pw.FontWeight.bold,
        color: text,
        letterSpacing: -0.6,
      );

  static pw.TextStyle h1({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: text,
      );

  static pw.TextStyle h2({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: text,
      );

  static pw.TextStyle body({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 11,
        color: text,
        lineSpacing: 1.4,
      );

  static pw.TextStyle muted({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 10,
        color: text3,
      );

  static pw.TextStyle eyebrow({pw.Font? font}) => pw.TextStyle(
        font: font,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: accent,
        letterSpacing: 1.2,
      );

  static pw.TextStyle mono({pw.Font? font, double size = 11, PdfColor? color}) =>
      pw.TextStyle(
        font: font,
        fontSize: size,
        color: color ?? text,
        fontWeight: pw.FontWeight.normal,
      );

  static pw.TextStyle monoBold(
          {pw.Font? font, double size = 14, PdfColor? color}) =>
      pw.TextStyle(
        font: font,
        fontSize: size,
        color: color ?? text,
        fontWeight: pw.FontWeight.bold,
      );
}
