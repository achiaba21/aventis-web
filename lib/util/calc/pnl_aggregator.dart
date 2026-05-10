import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';

/// Calcule le compte de résultat (`PnLCard`) du mois courant à partir des
/// réservations confirmées/payées/finalisées et des charges récurrentes.
///
/// Sortie : 6 segments compatibles `PnLCard` (revenueHeader, revenueDetails,
/// chargeHeader, chargeDetails, netIncome, netMargin) — calculés dynamiquement.
class PnLAggregator {
  PnLAggregator._();

  /// Frais plateforme Asfar prélevés sur les revenus bruts (6%).
  static const double _fraisAsfarRate = 0.06;

  /// Commission moyenne reversée aux démarcheurs (12% des locations
  /// référencées). Source : décision produit Asfar.
  static const double _commissionDemarcheurRate = 0.12;

  /// Construit le P&L pour le mois courant. Si aucune donnée, renvoie un PnL
  /// vide (montants à 0) — l'UI affichera un EmptyState.
  static PnLBreakdown currentMonth({
    required List<Reservation> reservations,
    required List<Charge> charges,
  }) {
    final now = DateTime.now();
    return _buildBreakdown(
      reservations: reservations,
      charges: charges,
      year: now.year,
      month: now.month,
    );
  }

  static PnLBreakdown _buildBreakdown({
    required List<Reservation> reservations,
    required List<Charge> charges,
    required int year,
    required int month,
  }) {
    int locationsBrutes = 0;
    int nuitsTotales = 0;

    for (final r in reservations) {
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != year || r.debut!.month != month) continue;
      if (!_isCounted(r.statut)) continue;
      locationsBrutes += r.prix!.round();
      if (r.fin != null) {
        final n = r.fin!.difference(r.debut!).inDays;
        if (n > 0) nuitsTotales += n;
      }
    }

    final revenueDetails = <PnLEntry>[
      PnLEntry(
        label: 'Locations brutes ($nuitsTotales nuits)',
        amount: locationsBrutes,
        kind: PnLKind.categoryDetail,
        isRevenue: true,
      ),
    ];
    final revenueTotal = locationsBrutes;
    final revenueHeader = PnLEntry(
      label: '+ Revenus',
      amount: revenueTotal,
      kind: PnLKind.categoryHeader,
      isRevenue: true,
    );

    final fraisAsfar = (locationsBrutes * _fraisAsfarRate).round();
    final commissionDemarcheurs =
        (locationsBrutes * _commissionDemarcheurRate).round();

    final chargesDuMois = _aggregateChargesForMonth(charges, year, month);
    final chargeDetails = <PnLEntry>[
      PnLEntry(
        label: 'Frais plateforme Asfar (6%)',
        amount: fraisAsfar,
        kind: PnLKind.categoryDetail,
        isRevenue: false,
      ),
      PnLEntry(
        label: 'Commissions démarcheurs',
        amount: commissionDemarcheurs,
        kind: PnLKind.categoryDetail,
        isRevenue: false,
      ),
      ...chargesDuMois,
    ];

    final chargesTotal = fraisAsfar +
        commissionDemarcheurs +
        chargesDuMois.fold<int>(0, (s, e) => s + e.amount);

    final chargeHeader = PnLEntry(
      label: '− Charges',
      amount: chargesTotal,
      kind: PnLKind.categoryHeader,
      isRevenue: false,
    );

    final benefice = revenueTotal - chargesTotal;
    final marge = revenueTotal == 0
        ? 0
        : ((benefice / revenueTotal) * 100).round();

    return PnLBreakdown(
      revenueHeader: revenueHeader,
      revenueDetails: revenueDetails,
      chargeHeader: chargeHeader,
      chargeDetails: chargeDetails,
      netIncome: PnLEntry(
        label: 'Bénéfice net',
        amount: benefice,
        kind: PnLKind.netIncome,
      ),
      netMargin: PnLEntry(
        label: 'Marge nette',
        amount: marge,
        kind: PnLKind.netMargin,
      ),
      isEmpty: revenueTotal == 0 && chargeDetails.length <= 2,
    );
  }

  static List<PnLEntry> _aggregateChargesForMonth(
      List<Charge> charges, int year, int month) {
    final grouped = <String, double>{};
    for (final c in charges) {
      if (c.montant == null) continue;
      if (!_isChargeOfMonth(c, year, month)) continue;
      final label = c.typeCharge.label;
      grouped.update(label, (v) => v + c.montant!,
          ifAbsent: () => c.montant!);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .map((e) => PnLEntry(
              label: e.key,
              amount: e.value.round(),
              kind: PnLKind.categoryDetail,
              isRevenue: false,
            ))
        .toList();
  }

  static bool _isChargeOfMonth(Charge c, int year, int month) {
    final pivot = c.datePaiement ?? c.dateEcheance ?? c.dateDebut;
    if (pivot == null) {
      // Charges récurrentes sans date pivot → comptées au mois courant
      // (montant mensuel équivalent).
      return c.estRecurrent == true;
    }
    return pivot.year == year && pivot.month == month;
  }

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }
}

/// Résultat compositionnel du `PnLAggregator` — directement passable à
/// `PnLCard`.
class PnLBreakdown {
  final PnLEntry revenueHeader;
  final List<PnLEntry> revenueDetails;
  final PnLEntry chargeHeader;
  final List<PnLEntry> chargeDetails;
  final PnLEntry netIncome;
  final PnLEntry netMargin;
  final bool isEmpty;

  const PnLBreakdown({
    required this.revenueHeader,
    required this.revenueDetails,
    required this.chargeHeader,
    required this.chargeDetails,
    required this.netIncome,
    required this.netMargin,
    required this.isEmpty,
  });
}
