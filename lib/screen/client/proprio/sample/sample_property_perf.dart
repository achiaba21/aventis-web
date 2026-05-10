import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';

/// Performance par bien — section « Performance par bien » du
/// `ProprioFinancesScreen`. Réutilise [SampleListings.all] (V5) pour les 4 biens.
///
/// Source : proto `proprietaire.jsx::ProprietaireFinances` (lignes 274-303),
/// deltas `[12, 8, 18, 14]` indexés sur les 4 biens.
class SamplePropertyPerf {
  SamplePropertyPerf._();

  static const List<int> _deltaPerBien = [12, 8, 18, 14];

  static List<PropertyPerf> get all {
    final listings = SampleListings.all;
    return [
      for (var i = 0; i < listings.length; i++)
        PropertyPerf(
          listing: listings[i],
          occupancyRate: _occupancyFor(i),
          monthlyRevenue: _monthlyRevenueFor(i),
          deltaPercent: _deltaPerBien[i],
        ),
    ];
  }

  /// Taux d'occupation déterministe par bien (0..1).
  static double _occupancyFor(int i) {
    const rates = [0.84, 0.71, 0.92, 0.88];
    return rates[i];
  }

  /// Revenus mensuels par bien (FCFA).
  static int _monthlyRevenueFor(int i) {
    const revs = [1245000, 720000, 2080000, 3500000];
    return revs[i];
  }
}
