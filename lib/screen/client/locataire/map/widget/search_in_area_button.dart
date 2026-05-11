import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Chip top-center "Rechercher dans cette zone".
///
/// Apparaît/disparaît avec une animation fade 200 ms via `AnimatedOpacity`.
/// `IgnorePointer` empêche les taps fantômes pendant l'invisibilité.
class SearchInAreaButton extends StatelessWidget {
  final bool visible;
  final VoidCallback? onTap;

  const SearchInAreaButton({
    super.key,
    required this.visible,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1.0 : 0.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgElev1.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.line, width: 1),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Rechercher dans cette zone',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
