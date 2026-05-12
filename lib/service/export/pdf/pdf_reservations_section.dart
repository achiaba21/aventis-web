import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/service/export/pdf/pdf_theme.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Section « Annexe — Détail des réservations encaissées » du PDF — page 4.
///
/// Tableau exhaustif des résa avec : code · dates · client · bien · brut ·
/// frais · net · type (avec nom démarcheur quand `ReservationDemarcheur`).
/// Sous-total cumulé en bas.
class PdfReservationsSection {
  PdfReservationsSection._();

  static const _monthsShort = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static pw.Widget build({required List<Reservation> reservations}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Annexe — Détail des réservations encaissées',
            style: PdfTheme.h1()),
        pw.SizedBox(height: 4),
        pw.Text(
          '${reservations.length} réservation${reservations.length > 1 ? 's' : ''} '
          'sur la période',
          style: PdfTheme.muted(),
        ),
        pw.SizedBox(height: 12),
        if (reservations.isEmpty)
          _emptyState()
        else
          _table(reservations),
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
          'Aucune réservation encaissée sur cette période.',
          style: PdfTheme.muted(),
        ),
      ),
    );
  }

  static pw.Widget _table(List<Reservation> reservations) {
    final totalBrut = reservations.fold<int>(
        0, (s, r) => s + ((r.prix ?? 0).round()));
    final totalFrais = reservations.fold<int>(
        0, (s, r) => s + ((r.frais ?? 0).round()));
    final totalNet = totalBrut - totalFrais;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfTheme.line, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.3),
          1: pw.FlexColumnWidth(1.6),
          2: pw.FlexColumnWidth(1.8),
          3: pw.FlexColumnWidth(2.0),
          4: pw.FlexColumnWidth(1.4),
          5: pw.FlexColumnWidth(1.0),
          6: pw.FlexColumnWidth(1.4),
        },
        children: [
          _headerRow(),
          for (final r in reservations) _dataRow(r),
          _totalRow(totalBrut, totalFrais, totalNet),
        ],
      ),
    );
  }

  static pw.TableRow _headerRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfTheme.bgSoft),
      children: [
        _headerCell('CODE'),
        _headerCell('DATES'),
        _headerCell('CLIENT'),
        _headerCell('BIEN · SOURCE'),
        _headerCell('BRUT', align: pw.TextAlign.right),
        _headerCell('FRAIS', align: pw.TextAlign.right),
        _headerCell('NET', align: pw.TextAlign.right),
      ],
    );
  }

  static pw.TableRow _dataRow(Reservation r) {
    final code = r.codeReservation?.secretKey ?? r.reference ?? 'RES-${r.id}';
    final brut = (r.prix ?? 0).round();
    final frais = (r.frais ?? 0).round();
    final net = brut - frais;

    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfTheme.line, width: 0.5),
        ),
      ),
      children: [
        _bodyCell(code, mono: true, size: 9),
        _bodyCell(_formatDates(r.debut, r.fin), size: 9),
        _bodyCell(r.clientNom?.trim().isNotEmpty == true
            ? r.clientNom!
            : 'Client #${r.id}'),
        _bienAndSource(r),
        _bodyCell(FcfaFormatter.compact(brut),
            mono: true, align: pw.TextAlign.right),
        _bodyCell(FcfaFormatter.compact(frais),
            mono: true, align: pw.TextAlign.right, color: PdfTheme.text3),
        _bodyCell(FcfaFormatter.compact(net),
            mono: true,
            align: pw.TextAlign.right,
            bold: true),
      ],
    );
  }

  static pw.TableRow _totalRow(int brut, int frais, int net) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: PdfTheme.bgSoft,
        border: pw.Border(
          top: pw.BorderSide(color: PdfTheme.line, width: 1.5),
        ),
      ),
      children: [
        _bodyCell('TOTAL', bold: true, size: 10),
        _bodyCell(''),
        _bodyCell(''),
        _bodyCell(''),
        _bodyCell(FcfaFormatter.full(brut),
            mono: true, align: pw.TextAlign.right, bold: true),
        _bodyCell(FcfaFormatter.full(frais),
            mono: true,
            align: pw.TextAlign.right,
            bold: true,
            color: PdfTheme.text3),
        _bodyCell(FcfaFormatter.full(net),
            mono: true,
            align: pw.TextAlign.right,
            bold: true,
            color: PdfTheme.accent),
      ],
    );
  }

  static pw.Widget _bienAndSource(Reservation r) {
    final title = r.appart?.titleSafe ?? 'Logement';
    String? source;
    if (r is ReservationDemarcheur) {
      final demarcheurName = r.demarcheur?.fullName.trim();
      source = (demarcheurName?.isNotEmpty ?? false)
          ? 'Démarcheur · $demarcheurName'
          : 'Démarcheur';
    } else if (r.isManuelle) {
      source = 'Manuelle (externe)';
    } else {
      source = 'Direct';
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: PdfTheme.body().copyWith(fontSize: 9),
              maxLines: 1,
              overflow: pw.TextOverflow.clip),
          pw.SizedBox(height: 2),
          pw.Text(source, style: PdfTheme.muted().copyWith(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _headerCell(String text, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: PdfTheme.eyebrow().copyWith(fontSize: 8),
      ),
    );
  }

  static pw.Widget _bodyCell(String text,
      {bool mono = false,
      bool bold = false,
      pw.TextAlign? align,
      PdfColor? color,
      double size = 9}) {
    final base = mono
        ? PdfTheme.mono(size: size, color: color)
        : PdfTheme.body().copyWith(fontSize: size, color: color);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: bold ? base.copyWith(fontWeight: pw.FontWeight.bold) : base,
      ),
    );
  }

  static String _formatDates(DateTime? debut, DateTime? fin) {
    if (debut == null || fin == null) return '—';
    final d1 = debut.day;
    final d2 = fin.day;
    final m1 = _monthsShort[debut.month - 1];
    final m2 = _monthsShort[fin.month - 1];
    if (debut.month == fin.month && debut.year == fin.year) {
      return '$d1-$d2 $m1';
    }
    return '$d1 $m1 - $d2 $m2';
  }
}
