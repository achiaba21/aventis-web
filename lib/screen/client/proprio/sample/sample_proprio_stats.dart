import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/model/ui_only/proprio_kpi.dart';
import 'package:asfar/theme/app_colors.dart';

/// Données mock pour le Dashboard propriétaire — alignées sur le proto
/// `proprietaire.jsx::ProprietaireDashboard`.
class SampleProprioStats {
  SampleProprioStats._();

  /// Revenu du mois courant (FCFA) — affiché dans `RevenueHeroCard`.
  static const int monthlyRevenue = 1900000;

  /// Évolution % vs mois précédent (positif = success).
  static const int monthlyDeltaPercent = 20;

  /// Référence chiffrée octobre pour l'étiquette « vs. octobre · 1.58 M FCFA ».
  static const int previousMonthRevenue = 1580000;

  /// 6 mois de revenus pour le `Sparkbar` (Juin → Novembre).
  static const List<MonthlyRevenue> last6Months = [
    MonthlyRevenue(monthShort: 'Juin', amount: 740000),
    MonthlyRevenue(monthShort: 'Juil', amount: 820000),
    MonthlyRevenue(monthShort: 'Août', amount: 1100000),
    MonthlyRevenue(monthShort: 'Sept', amount: 1340000),
    MonthlyRevenue(monthShort: 'Oct', amount: 1580000),
    MonthlyRevenue(monthShort: 'Nov', amount: 1900000, highlight: true),
  ];

  /// 4 KPIs de la grid 2×2 (Occupation / ADR / Réservations / Note moy.).
  static const List<ProprioKpi> kpis = [
    ProprioKpi(label: 'Occupation', value: '84%', deltaPercent: 6),
    ProprioKpi(label: 'ADR moyen', value: '48k', deltaPercent: 4),
    ProprioKpi(label: 'Réservations', value: '42', deltaPercent: 12),
    ProprioKpi(label: 'Note moy.', value: '4.91', deltaPercent: 1),
  ];

  /// 4 segments du `CashflowSplitCard` — barre stack horizontale.
  static const List<CashflowSegment> cashflow = [
    CashflowSegment(
      label: 'Locations nettes',
      amount: 1178000,
      color: AppColors.accent,
    ),
    CashflowSegment(
      label: 'Charges (entretien, eau, élec.)',
      amount: 380000,
      color: AppColors.cashflowCharges,
    ),
    CashflowSegment(
      label: 'Commissions démarcheurs',
      amount: 228000,
      color: AppColors.cardPay,
    ),
    CashflowSegment(
      label: 'Frais plateforme',
      amount: 114000,
      color: AppColors.text3,
    ),
  ];
}
