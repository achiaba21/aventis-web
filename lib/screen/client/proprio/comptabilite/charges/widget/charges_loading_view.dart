import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Skeleton de la liste des charges pendant le chargement initial.
///
/// Reproduit la structure réelle : 4-5 cards grises à la place des rows.
class ChargesLoadingView extends StatelessWidget {
  const ChargesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          border: Border.all(color: AppColors.line, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }
}
