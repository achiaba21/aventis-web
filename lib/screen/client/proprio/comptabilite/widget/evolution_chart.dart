import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class EvolutionChart extends StatefulWidget {
  final List<PointEvolution> historique;

  const EvolutionChart({super.key, required this.historique});

  @override
  State<EvolutionChart> createState() => _EvolutionChartState();
}

class _EvolutionChartState extends State<EvolutionChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.historique.isEmpty) {
      return _EmptyChartView();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextSeed(
                "Évolution",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              _Legend(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              _buildChartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    final maxY = _getMaxY();
    // Éviter l'interval 0 quand maxY est 0
    final interval = maxY > 0 ? maxY / 4 : 1.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.historique.length) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: TextSeed(
                  widget.historique[index].moisLabel,
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: interval,
            getTitlesWidget: (value, meta) {
              return TextSeed(
                formatAxisValue(value),
                fontSize: 10,
                color: AppColors.textMuted,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (widget.historique.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.background,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              String label;
              Color color;

              if (barSpot.barIndex == 0) {
                label = "CA: ${formatMontantCourt(barSpot.y)}";
                color = AppColors.success;
              } else if (barSpot.barIndex == 1) {
                label = "Charges: ${formatMontantCourt(barSpot.y)}";
                color = AppColors.error;
              } else {
                label = "Bénéfice: ${formatMontantCourt(barSpot.y)}";
                color = AppColors.accent;
              }

              return LineTooltipItem(
                label,
                TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse?.lineBarSpots != null &&
                touchResponse!.lineBarSpots!.isNotEmpty) {
              _touchedIndex = touchResponse.lineBarSpots![0].x.toInt();
            } else {
              _touchedIndex = -1;
            }
          });
        },
      ),
      lineBarsData: [
        // Ligne CA (vert)
        _buildLineData(
          spots: widget.historique.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.chiffreAffaires);
          }).toList(),
          color: AppColors.success,
        ),
        // Ligne Charges (rouge)
        _buildLineData(
          spots: widget.historique.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.charges);
          }).toList(),
          color: AppColors.error,
        ),
        // Ligne Bénéfice (primaire)
        _buildLineData(
          spots: widget.historique.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.benefice.abs());
          }).toList(),
          color: AppColors.accent,
          isDashed: true,
        ),
      ],
    );
  }

  LineChartBarData _buildLineData({
    required List<FlSpot> spots,
    required Color color,
    bool isDashed = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dashArray: isDashed ? [5, 5] : null,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: _touchedIndex == index ? 6 : 4,
            color: color,
            strokeWidth: 2,
            strokeColor: AppColors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final point in widget.historique) {
      if (point.chiffreAffaires > max) max = point.chiffreAffaires;
      if (point.charges > max) max = point.charges;
      if (point.benefice.abs() > max) max = point.benefice.abs();
    }
    // Retourner au minimum 100 pour éviter les divisions par 0
    if (max == 0) return 100;
    return max * 1.2; // Ajouter 20% de marge
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: AppColors.success, label: "CA"),
        const SizedBox(width: 12),
        _LegendItem(color: AppColors.error, label: "Charges"),
        const SizedBox(width: 12),
        _LegendItem(color: AppColors.accent, label: "Bénéf.", isDashed: true),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: isDashed
              ? Row(
                  children: [
                    Container(width: 4, height: 3, color: color),
                    const SizedBox(width: 2),
                    Container(width: 4, height: 3, color: color),
                    const SizedBox(width: 2),
                    Container(width: 4, height: 3, color: color),
                  ],
                )
              : null,
        ),
        const SizedBox(width: 4),
        TextSeed(label, fontSize: 10, color: AppColors.textMuted),
      ],
    );
  }
}

class _EmptyChartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.show_chart, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          TextSeed(
            "Pas assez de données",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          TextSeed(
            "Le graphique d'évolution s'affichera après plusieurs mois d'activité",
            textAlign: TextAlign.center,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
