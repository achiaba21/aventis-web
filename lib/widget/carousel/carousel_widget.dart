import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Carousel générique réutilisable
class CarouselWidget extends StatefulWidget {
  /// Liste des éléments à afficher dans le carousel
  final List<CarouselItem> items;

  /// Hauteur du carousel (par défaut 320)
  final double height;

  /// Afficher les indicateurs en haut (true) ou en bas (false)
  final bool indicatorsOnTop;

  /// Espacement entre les indicateurs et le contenu
  final double indicatorSpacing;

  /// Callback quand la page change
  final Function(int index)? onPageChanged;

  const CarouselWidget({
    super.key,
    required this.items,
    this.height = 320,
    this.indicatorsOnTop = true,
    this.indicatorSpacing = 12,
    this.onPageChanged,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si aucun élément, ne rien afficher
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Si un seul élément, pas besoin de carousel
    if (widget.items.length == 1) {
      return SizedBox(
        height: widget.height,
        child: widget.items.first.child,
      );
    }

    final indicator = _PageIndicator(
      count: widget.items.length,
      currentIndex: _currentPage,
      labels: widget.items.map((item) => item.label).toList(),
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );

    final pageView = SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          widget.onPageChanged?.call(index);
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: widget.items[index].child,
          );
        },
      ),
    );

    return Column(
      children: widget.indicatorsOnTop
          ? [
              indicator,
              SizedBox(height: widget.indicatorSpacing),
              pageView,
            ]
          : [
              pageView,
              SizedBox(height: widget.indicatorSpacing),
              indicator,
            ],
    );
  }
}

/// Élément du carousel
class CarouselItem {
  /// Label affiché dans l'indicateur
  final String label;

  /// Widget à afficher
  final Widget child;

  const CarouselItem({
    required this.label,
    required this.child,
  });
}

/// Indicateur de page avec labels cliquables
class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final List<String> labels;
  final Function(int) onTap;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < count - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicateur
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Label
                  TextSeed(
                    labels[index],
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.white : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
