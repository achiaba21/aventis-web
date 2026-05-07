import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';

class Block extends StatelessWidget {
  const Block({super.key, this.child, this.color});
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: child,
    );
  }
}
