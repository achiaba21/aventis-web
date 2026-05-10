import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Header du `MiniCalendarGrid` : chevron prev + titre mois + chevron next.
class MiniCalendarHeader extends StatelessWidget {
  final String monthTitle;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const MiniCalendarHeader({
    super.key,
    required this.monthTitle,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPrev,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.text2),
          ),
        ),
        Text(monthTitle, style: AppTextStyles.h3),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.text2),
          ),
        ),
      ],
    );
  }
}
