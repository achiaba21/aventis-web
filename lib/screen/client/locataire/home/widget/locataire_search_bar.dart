import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Search bar tappable du Home Locataire.
///
/// Card `bgElev2` cliquable avec icon search + titre + sub (destination ·
/// dates · voyageurs) + bouton sliders 38×38 accent or à droite.
class LocataireSearchBar extends StatelessWidget {
  final String title;
  final String summary;
  final VoidCallback? onTap;
  final VoidCallback? onFiltersTap;

  const LocataireSearchBar({
    super.key,
    this.title = 'Où voulez-vous séjourner ?',
    required this.summary,
    this.onTap,
    this.onFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.search,
                  size: 20, color: AppColors.text2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: AppTextStyles.small.copyWith(
                          fontSize: 12, color: AppColors.text3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFiltersTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    size: 18,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
