import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

class Block2 extends StatelessWidget {
  const Block2({super.key, this.child, this.color, this.padding});
  final Widget? child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: color ?? AppColors.background),
      child: child,
    );
  }
}
