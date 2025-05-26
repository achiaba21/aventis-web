import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';

class TextSeed extends StatelessWidget {
  const TextSeed(
    this.data, {
    super.key,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
  });
  final String? data;
  final int? maxLines;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data ?? "",
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color ?? Style.textColor(context),
      ),
    );
  }
}
