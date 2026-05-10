import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Badge de note flottant — étoile accent + valeur.
///
/// Pill rgba(10,10,11,0.7) blanche, utilisé sur les images de listing
/// (FeaturedCard, Detail hero).
class RatingChip extends StatelessWidget {
  final double rating;
  const RatingChip({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xB30A0A0B),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 11, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
