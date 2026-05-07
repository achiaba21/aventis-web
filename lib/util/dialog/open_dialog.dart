import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/dialog/close_header.dart';

void dialogBottomSheet(
  BuildContext context,
  Widget child, {
  bool hide = false,
}) {
  showBottomSheet(
    backgroundColor: AppColors.background,
    context: context,
    builder:
        (context) => Column(
          children: [if (!hide) CloseHeader(), Expanded(child: child)],
        ),
  );
}
