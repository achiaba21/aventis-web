import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Card d'avis dans le carrousel du Detail.
///
/// 5 stars accent or + citation 13px + avatar 28 + nom + date.
class ReviewCard extends StatelessWidget {
  final String name;
  final String text;
  final String date;
  final int starCount;
  final double width;

  const ReviewCard({
    super.key,
    required this.name,
    required this.text,
    required this.date,
    this.starCount = 5,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              starCount,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(Icons.star, size: 11, color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$text"',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              UserAvatar(name: name, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      date,
                      style: AppTextStyles.small.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
