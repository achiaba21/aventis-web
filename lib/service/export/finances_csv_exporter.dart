import 'package:csv/csv.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/util/calc/finance_period.dart';

/// Exporte les données Finances en CSV (séparateur `;` pour Excel
/// francophone, encodage UTF-8 avec BOM ajouté par `ExportShareHelper`).
///
/// Le CSV contient les mêmes données que l'annexe page 4 du PDF — 1 ligne
/// par réservation encaissée + métadonnées de période en tête.
class FinancesCsvExporter {
  FinancesCsvExporter._();

  static String build({
    required FinancePeriod period,
    required int year,
    required int index,
    required List<Reservation> reservationsEncaissed,
  }) {
    final rows = <List<dynamic>>[
      // Métadonnées
      ['Asfar — Rapport Finances'],
      ['Période', period.longLabel(year, index)],
      ['Généré le', _formatGenDate(DateTime.now())],
      [],
      // Header tableau
      [
        'Code',
        'Date début',
        'Date fin',
        'Client',
        'Bien',
        'Source',
        'Démarcheur',
        'Prix brut (FCFA)',
        'Frais (FCFA)',
        'Net (FCFA)',
        'Commission démarcheur (FCFA)',
        'Statut',
      ],
    ];

    int totalBrut = 0;
    int totalFrais = 0;
    int totalNet = 0;
    int totalCommission = 0;

    for (final r in reservationsEncaissed) {
      final brut = (r.prix ?? 0).round();
      final frais = (r.frais ?? 0).round();
      final net = brut - frais;
      final commission =
          r is ReservationDemarcheur ? (r.montantCommission ?? 0).round() : 0;

      totalBrut += brut;
      totalFrais += frais;
      totalNet += net;
      totalCommission += commission;

      final code = r.codeReservation?.secretKey ??
          r.reference ??
          'RES-${r.id ?? 0}';
      final source = r is ReservationDemarcheur
          ? 'Démarcheur'
          : r.isManuelle
              ? 'Manuelle'
              : 'Direct';
      final demarcheurName = r is ReservationDemarcheur
          ? (r.demarcheur?.fullName.trim() ?? '')
          : '';

      rows.add([
        code,
        _formatDate(r.debut),
        _formatDate(r.fin),
        r.clientNom?.trim() ?? '',
        r.appart?.titleSafe ?? '',
        source,
        demarcheurName,
        brut,
        frais,
        net,
        commission,
        r.statut?.value ?? '',
      ]);
    }

    // Ligne total
    rows.add([]);
    rows.add([
      'TOTAL',
      '', '', '', '', '', '',
      totalBrut,
      totalFrais,
      totalNet,
      totalCommission,
      '',
    ]);

    const converter = ListToCsvConverter(fieldDelimiter: ';', eol: '\r\n');
    return converter.convert(rows);
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  static String _formatGenDate(DateTime dt) {
    return '${_formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
