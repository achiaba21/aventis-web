import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';
import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/charge_period_filter.dart';
import 'package:asfar/util/calc/reservation_finance_extensions.dart';

/// Calcule les segments du `CashflowSplitCard` (Dashboard proprio) depuis
/// reservations + charges du mois courant.
///
/// 4 segments fidèles au proto `proprietaire.jsx::ProprietaireDashboard` :
/// - Locations nettes (revenus - frais Asfar - commissions)  → `accent`
/// - Charges (entretien, eau, élec.)                          → `cashflowCharges`
/// - Commissions démarcheurs (montant réel backend)           → `cardPay`
/// - Frais plateforme (montant réel backend `r.frais`)        → `text3`
///
/// Si aucune donnée pour le mois courant, retourne une liste vide (le
/// CashflowSplitCard se cache).
class CashflowAggregator {
  CashflowAggregator._();

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }

  static List<CashflowSegment> currentMonth({
    required List<Reservation> reservations,
    required List<Charge> charges,
  }) {
    final now = DateTime.now();
    return forMonth(
      reservations: reservations,
      charges: charges,
      year: now.year,
      month: now.month,
    );
  }

  static List<CashflowSegment> forMonth({
    required List<Reservation> reservations,
    required List<Charge> charges,
    required int year,
    required int month,
  }) {
    int grossRevenue = 0;
    int demarcheurCommissions = 0;

    for (final r in reservations) {
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != year || r.debut!.month != month) continue;
      if (!_isCounted(r.statut)) continue;
      grossRevenue += r.prix!.round();
      final commission = r.demarcheurCommissionAmount;
      if (commission > 0) {
        demarcheurCommissions += commission.round();
      }
    }

    int chargesTotal = 0;
    for (final c in charges) {
      if (c.montant == null) continue;
      if (!ChargePeriodFilter.includes(c, year: year, month: month)) continue;
      chargesTotal += c.montant!.round();
    }

    // Frais Asfar : somme réelle de `r.frais` envoyée par le backend pour
    // chaque résa encaissée du mois — plus de taux % côté Flutter.
    final platformFees = reservations.sumEncaissedFraisForMonth(
      year: year, month: month,
    );
    final netRevenue =
        grossRevenue - platformFees - demarcheurCommissions - chargesTotal;

    final segments = <CashflowSegment>[];
    if (netRevenue > 0) {
      segments.add(CashflowSegment(
        label: 'Locations nettes',
        amount: netRevenue,
        color: AppColors.accent,
      ));
    }
    if (chargesTotal > 0) {
      segments.add(CashflowSegment(
        label: 'Charges (entretien, eau, élec.)',
        amount: chargesTotal,
        color: AppColors.cashflowCharges,
      ));
    }
    if (demarcheurCommissions > 0) {
      segments.add(CashflowSegment(
        label: 'Commissions démarcheurs',
        amount: demarcheurCommissions,
        color: AppColors.cardPay,
      ));
    }
    if (platformFees > 0) {
      segments.add(CashflowSegment(
        label: 'Frais plateforme',
        amount: platformFees,
        color: AppColors.text3,
      ));
    }
    return segments;
  }
}
