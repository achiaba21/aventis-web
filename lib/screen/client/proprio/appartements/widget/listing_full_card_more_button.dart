import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton circulaire 32×32 « more horizontal » blur top-right d'une
/// `ListingFullCard`.
class ListingFullCardMoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ListingFullCardMoreButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background.withValues(alpha: 0.6),
          ),
          child: const Icon(Icons.more_horiz, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
