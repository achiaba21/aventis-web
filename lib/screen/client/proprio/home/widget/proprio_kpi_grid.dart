import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/proprio_kpi.dart';
import 'package:asfar/screen/client/proprio/home/widget/kpi_tile.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Grille 2×2 des KPI du dashboard propriétaire.
///
/// Affiche un `EmptyState.inline` si moins de 4 KPI disponibles
/// (chargement initial).
class ProprioKpiGrid extends StatelessWidget {
  final List<ProprioKpi> kpis;

  const ProprioKpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    if (kpis.length < 4) {
      return EmptyState.inline(
        icon: Icons.bar_chart_outlined,
        title: 'Stats indisponibles',
        body: 'Les statistiques se chargent…',
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: KpiTile(kpi: kpis[0])),
            const SizedBox(width: 10),
            Expanded(child: KpiTile(kpi: kpis[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: KpiTile(kpi: kpis[2])),
            const SizedBox(width: 10),
            Expanded(child: KpiTile(kpi: kpis[3])),
          ],
        ),
      ],
    );
  }
}
