import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DynamicAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
  });

  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      title: title != null ? TextSeed(title!) : null,
      actions: actions,
    );
  }
}