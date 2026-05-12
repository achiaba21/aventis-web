import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/calc/reservation_finance_extensions.dart';

/// Calcule le compte de résultat (`PnLCard`) pour une période donnée.
///
/// Toutes les agrégations passent par l'extension `ReservationFinance` sur
/// `Iterable<Reservation>` pour garantir la cohérence avec les autres
/// calculators (RevenueHeroCard, PropertyPerf, etc.).
class PnLAggregator {
  PnLAggregator._();

  /// Frais plateforme Asfar prélevés sur les revenus bruts (6%).
  static const double _fraisAsfarRate = 0.06;

  /// Commission reversée aux démarcheurs (12% des locations référées).
  static const double _commissionDemarcheurRate = 0.12;

  static PnLBreakdown forPeriod({
    required List<Reservation> reservations,
    required List<Charge> charges,
    required FinancePeriod period,
    required int year,
    required int index,
  }) {
    final locationsBrutes = reservations.sumEncaissedNet(
      period: period, year: year, index: index,
    );
    final locationsBrutesDemarcheur = reservations.sumEncaissedNetReferred(
      period: period, year: year, index: index,
    );
    final pipelineBrutes = reservations.sumPipelineNet(
      period: period, year: year, index: index,
    );
    final nuitsTotales = reservations.sumEncaissedNightsIn(
      period: period, year: year, index: index,
    );

    final revenueDetails = <PnLEntry>[
      PnLEntry(
        label: 'Locations brutes ($nuitsTotales nuits)',
        amount: locationsBrutes,
        kind: PnLKind.categoryDetail,
        isRevenue: true,
      ),
    ];
    final revenueHeader = PnLEntry(
      label: '+ Revenus',
      amount: locationsBrutes,
      kind: PnLKind.categoryHeader,
      isRevenue: true,
    );

    final fraisAsfar = (locationsBrutes * _fraisAsfarRate).round();
    final commissionDemarcheurs =
        (locationsBrutesDemarcheur * _commissionDemarcheurRate).round();

    final chargesDuMois =
        _aggregateChargesForPeriod(charges, period, year, index);
    final chargeDetails = <PnLEntry>[
      if (fraisAsfar > 0)
        PnLEntry(
          label: 'Frais plateforme Asfar (6%)',
          amount: fraisAsfar,
          kind: PnLKind.categoryDetail,
          isRevenue: false,
        ),
      if (commissionDemarcheurs > 0)
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

    final benefice = locationsBrutes - chargesTotal;
    final marge = locationsBrutes == 0
        ? 0
        : ((benefice / locationsBrutes) * 100).round();

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
      pipelineRevenue: pipelineBrutes,
      isEmpty: locationsBrutes == 0 && chargesDuMois.isEmpty,
    );
  }

  static List<PnLEntry> _aggregateChargesForPeriod(
    List<Charge> charges,
    FinancePeriod period,
    int year,
    int index,
  ) {
    final grouped = <String, double>{};
    for (final c in charges) {
      if (c.montant == null) continue;
      if (!_chargeFallsInPeriod(c, period, year, index)) continue;
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

  static bool _chargeFallsInPeriod(
    Charge c,
    FinancePeriod period,
    int year,
    int index,
  ) {
    final pivot = c.datePaiement ?? c.dateEcheance ?? c.dateDebut;
    if (pivot == null) {
      return c.estRecurrent == true;
    }
    return period.contains(year, index, pivot);
  }
}

/// Résultat compositionnel du `PnLAggregator` — directement passable à
/// `PnLCard`. Le `pipelineRevenue` (résa confirmees non encore payées) est
/// exposé pour affichage en trace sous le bénéfice.
class PnLBreakdown {
  final PnLEntry revenueHeader;
  final List<PnLEntry> revenueDetails;
  final PnLEntry chargeHeader;
  final List<PnLEntry> chargeDetails;
  final PnLEntry netIncome;
  final PnLEntry netMargin;
  final int pipelineRevenue;
  final bool isEmpty;

  const PnLBreakdown({
    required this.revenueHeader,
    required this.revenueDetails,
    required this.chargeHeader,
    required this.chargeDetails,
    required this.netIncome,
    required this.netMargin,
    required this.isEmpty,
    this.pipelineRevenue = 0,
  });
}
