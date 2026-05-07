import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  final String status;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingInput / 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(Espacement.radius / 2),
      ),
      child: TextSeed(
        status,
        color: AppColors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.success;
      case 'under review':
        return AppColors.warning;
      case 'draft':
        return AppColors.textMuted;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}