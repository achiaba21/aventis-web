import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({
    super.key,
    required this.title,
    required this.format,
    required this.status,
    required this.onDelete,
  });

  final String title;
  final String format;
  final String status;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isApproved = status.toUpperCase() == 'APPROVED';
    final isPending = status.toUpperCase() == 'PENDING';

    return Container(
      width: 160,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextSeed(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.purple,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isApproved
                  ? AppColors.success
                  : isPending
                      ? AppColors.warning
                      : AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextSeed(
              status,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isApproved
                  ? AppColors.success
                  : isPending
                      ? AppColors.warning
                      : AppColors.error,
            ),
          ),
          SizedBox(height: 8),
          TextSeed(
            format.toUpperCase(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
