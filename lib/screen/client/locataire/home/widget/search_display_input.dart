import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Pseudo-input pour la `LocataireSearchScreen` — affiche une valeur en
/// readonly avec une icône leading.
class SearchDisplayInput extends StatelessWidget {
  final String value;
  final IconData icon;

  const SearchDisplayInput({
    super.key,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.text3),
          const SizedBox(width: 10),
          Text(value,
              style: const TextStyle(fontSize: 15, color: AppColors.text)),
        ],
      ),
    );
  }
}
