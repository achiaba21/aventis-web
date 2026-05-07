import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Espacement.gapSection * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
          if (subtitle != null) ...[
            SizedBox(height: Espacement.gapSection / 2),
            TextSeed(
              subtitle!,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: Espacement.gapSection),
          child,
        ],
      ),
    );
  }
}