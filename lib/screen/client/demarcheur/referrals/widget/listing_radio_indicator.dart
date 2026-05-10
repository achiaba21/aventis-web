import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cercle radio 22×22 affichant l'état sélectionné/non du
/// `ReferralListingRadio`.
class ListingRadioIndicator extends StatelessWidget {
  final bool selected;

  const ListingRadioIndicator({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.line,
          width: 2,
        ),
        color: selected ? AppColors.accent : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: AppColors.onAccent)
          : null,
    );
  }
}
