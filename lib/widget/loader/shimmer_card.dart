import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Skeleton pulsé du design system Asfar Premium.
///
/// Bloc rectangulaire animé entre `bgElev2` et `bgElev3` pour matérialiser
/// les zones en chargement (cards, lignes de texte, listings).
class ShimmerCard extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadii.md,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final color = Color.lerp(
          AppColors.bgElev2,
          AppColors.bgElev3,
          _controller.value,
        )!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
