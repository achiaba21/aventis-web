import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

class CloseHeader extends StatelessWidget {
  const CloseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Row(
        children: [
          IconBoutton(
            icon: Icons.close,
            onPressed: () => back(context),
          ),
        ],
      ),
    );
  }
}
