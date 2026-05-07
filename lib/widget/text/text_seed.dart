import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

class TextSeed extends StatelessWidget {
  const TextSeed(
    this.data, {
    super.key,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow,
  });
  final String? data;
  final int? maxLines;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      data ?? "",
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}
