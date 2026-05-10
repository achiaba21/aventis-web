import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Widget de texte unifié du design system Asfar Premium.
///
/// 7 constructeurs nommés alignés sur le prototype HTML :
/// `display`, `h1`, `h2`, `h3`, `body`, `small`, `eyebrow`.
///
/// Le constructeur par défaut applique `body`. Le flag `mono` ajoute
/// `tabularFigures` pour aligner les colonnes financières.
class TextSeed extends StatelessWidget {
  final String text;
  final TextStyle _baseStyle;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool mono;
  final double? letterSpacing;

  const TextSeed(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.body;

  const TextSeed.display(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.display;

  const TextSeed.h1(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.h1;

  const TextSeed.h2(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.h2;

  const TextSeed.h3(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.h3;

  const TextSeed.body(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.body;

  const TextSeed.small(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.small;

  const TextSeed.eyebrow(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  }) : _baseStyle = AppTextStyles.eyebrow;

  const TextSeed.muted(
    this.text, {
    super.key,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  })  : _baseStyle = AppTextStyles.small,
        color = AppColors.text3;

  const TextSeed.accent(
    this.text, {
    super.key,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mono = false,
    this.letterSpacing,
  })  : _baseStyle = AppTextStyles.body,
        color = AppColors.accent;

  @override
  Widget build(BuildContext context) {
    var style = _baseStyle.copyWith(
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
    if (mono) {
      style = AppTextStyles.mono(style);
    }
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
