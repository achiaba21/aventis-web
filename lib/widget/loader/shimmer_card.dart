import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget affichant un effet shimmer (skeleton) pour simuler le chargement
///
/// Utilisé pendant le chargement en arrière-plan des données
/// pour améliorer l'UX en montrant un placeholder animé
class ShimmerCard extends StatefulWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation shimmer
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Répéter l'animation indéfiniment

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      AppColors.surface,
                      AppColors.textSecondary,
                      AppColors.surface,
                    ]
                  : [
                      AppColors.border,
                      AppColors.border,
                      AppColors.border,
                    ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Widget affichant un skeleton d'une carte d'appartement
///
/// Utilisé pour simuler le chargement d'une carte d'appartement
class AppartementShimmerCard extends StatelessWidget {
  const AppartementShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const ShimmerCard(
            height: 200,
            width: double.infinity,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),

          // Content placeholder
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const ShimmerCard(
                  height: 20,
                  width: 200,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const ShimmerCard(
                  height: 16,
                  width: 150,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 12),

                // Price and rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerCard(
                      height: 24,
                      width: 100,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const ShimmerCard(
                      height: 20,
                      width: 60,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget affichant un skeleton d'une liste d'appartements
///
/// Affiche plusieurs cartes shimmer pour simuler une liste
class AppartementListShimmer extends StatelessWidget {
  final int itemCount;

  const AppartementListShimmer({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppartementShimmerCard(),
    );
  }
}

/// Widget affichant un skeleton d'une ligne de liste simple
///
/// Utilisé pour les listes de réservations, conversations, etc.
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar/Icon placeholder
          const ShimmerCard(
            height: 50,
            width: 50,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerCard(
                  height: 16,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 8),
                const ShimmerCard(
                  height: 14,
                  width: 200,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget affichant un skeleton d'une liste simple
class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const ListItemShimmer(),
    );
  }
}
