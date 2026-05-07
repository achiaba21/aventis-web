import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

class CircularProgress extends StatelessWidget {
  const CircularProgress({super.key, this.color, this.value});

  final Color? color;
  final double? value;
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color ?? AppColors.accent,
      value: value,
    );
  }
}
