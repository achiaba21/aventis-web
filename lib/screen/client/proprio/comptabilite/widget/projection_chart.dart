import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asfar/model/ui_only/projection_point.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Line chart « Projection 3 mois » du `ProprioFinancesScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 305-345) avec `fl_chart` 0.69 :
/// - 2 séries : passé (solid) et futur (dashed) avec pivot point sur Nov pour
///   continuité visuelle
/// - Area gradient or alpha 0.4 → 0 sous la courbe complète
/// - Vertical line séparateur passé/futur dashed sur Nov
/// - Marker accent or sur Nov
/// - Labels mois en bas (Nov en accent + bold)
///
/// Eyebrow + montant Q1 estimation + badge « ★ Haute saison » au-dessus.
class ProjectionChart extends StatelessWidget {
  final List<ProjectionPoint> points;
  final int q1Estimation;

  const ProjectionChart({
    super.key,
    required this.points,
    required this.q1Estimation,
  });

  int get _currentIndex => points.indexWhere((p) => p.isCurrent);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATION Q1 2026',
                  style: AppTextStyles.eyebrow.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  FcfaFormatter.compact(q1Estimation),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  )),
                ),
              ],
            ),
            const BadgeStatus(text: '★ Haute saison', tone: BadgeTone.accent),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(height: 80, child: LineChart(_chartData())),
        const SizedBox(height: 8),
        _monthLabels(),
      ],
    );
  }

  LineChartData _chartData() {
    final pastSpots = <FlSpot>[];
    final futureSpots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final spot = FlSpot(i.toDouble(), p.amount.toDouble());
      if (p.isProjection) {
        futureSpots.add(spot);
      } else {
        pastSpots.add(spot);
        if (i < points.length - 1 && points[i + 1].isProjection) {
          futureSpots.add(spot);
        }
      }
    }

    final allSpots = [...pastSpots, ...futureSpots.where((s) =>
        !pastSpots.any((p) => p.x == s.x))];
    allSpots.sort((a, b) => a.x.compareTo(b.x));

    return LineChartData(
      minY: 0,
      maxY: points.map((p) => p.amount).reduce((a, b) => a > b ? a : b) * 1.1,
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      extraLinesData: ExtraLinesData(
        verticalLines: [
          if (_currentIndex >= 0)
            VerticalLine(
              x: _currentIndex.toDouble(),
              color: AppColors.accent.withValues(alpha: 0.3),
              dashArray: [2, 2],
              strokeWidth: 1,
            ),
        ],
      ),
      lineBarsData: [
        LineChartBarData(
          spots: allSpots,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.accent.withValues(alpha: 0.4),
                AppColors.accent.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: pastSpots,
          color: AppColors.accent,
          barWidth: 2,
          isCurved: false,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: futureSpots,
          color: AppColors.accent,
          barWidth: 2,
          isCurved: false,
          dashArray: [4, 4],
          dotData: const FlDotData(show: false),
        ),
        if (_currentIndex >= 0)
          LineChartBarData(
            spots: [
              FlSpot(_currentIndex.toDouble(),
                  points[_currentIndex].amount.toDouble()),
            ],
            color: Colors.transparent,
            barWidth: 0,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                strokeWidth: 0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _monthLabels() {
    return Row(
      children: [
        for (var i = 0; i < points.length; i++)
          Expanded(
            child: Text(
              points[i].monthShort,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: points[i].isCurrent
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: points[i].isCurrent
                    ? AppColors.accent
                    : AppColors.text3,
              ),
            ),
          ),
      ],
    );
  }
}
