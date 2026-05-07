import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Graphique de répartition du CA par résidence ou appartement
class RepartitionCaChart extends StatefulWidget {
  final List<RepartitionCaItem> items;
  final String title;
  final bool isAppartementMode;

  const RepartitionCaChart({
    super.key,
    required this.items,
    required this.title,
    this.isAppartementMode = false,
  });

  @override
  State<RepartitionCaChart> createState() => _RepartitionCaChartState();
}

class _RepartitionCaChartState extends State<RepartitionCaChart> {
  int _touchedIndex = -1;

  // Palette de couleurs pour les segments
  static const List<Color> _colors = [
    Color(0xFF4CAF50), // Vert
    Color(0xFF2196F3), // Bleu
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Violet
    Color(0xFFE91E63), // Rose
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Jaune
    Color(0xFF795548), // Marron
    Color(0xFF607D8B), // Gris bleu
    Color(0xFFFF5722), // Orange foncé
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _EmptyView(isAppartementMode: widget.isAppartementMode);
    }

    final total = widget.items.fold(0.0, (sum, item) => sum + item.montant);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(widget.title, fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          TextSeed(
            "Total: ${formatMontantCompactFCFA(total)}",
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                pieTouchResponse
                                    .touchedSection!
                                    .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildSections(total),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Légende
              Expanded(flex: 2, child: _buildLegend(total)),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = (item.montant / total * 100);

      return PieChartSectionData(
        color: _colors[index % _colors.length],
        value: item.montant,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        badgeWidget:
            isTouched
                ? _Badge(
                  color: _colors[index % _colors.length],
                  montant: formatMontantCompactFCFA(item.montant),
                )
                : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegend(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:
          widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percentage = (item.montant / total * 100);
            final isTouched = index == _touchedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _touchedIndex = _touchedIndex == index ? -1 : index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isTouched
                          ? _colors[index % _colors.length].withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colors[index % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextSeed(
                            item.nom,

                            fontSize: 11,
                            fontWeight:
                                isTouched ? FontWeight.bold : FontWeight.normal,
                            color: isTouched ? AppColors.textPrimary : AppColors.textSecondary,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextSeed(
                            '${percentage.toStringAsFixed(1)}%',
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final String montant;

  const _Badge({required this.color, required this.montant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextSeed(
        montant,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isAppartementMode;

  const _EmptyView({this.isAppartementMode = false});

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
          Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          TextSeed(
            "Aucune donnée",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          TextSeed(
            isAppartementMode
                ? "Sélectionnez une résidence pour voir la répartition par appartement"
                : "Aucun chiffre d'affaires sur cette période",
            textAlign: TextAlign.center,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
