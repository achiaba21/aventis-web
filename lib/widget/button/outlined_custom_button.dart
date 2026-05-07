import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton outlined personnalisé avec le style de l'application
class OutlinedCustomButton extends StatelessWidget {
  const OutlinedCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.accent;
    final buttonTextColor = textColor ?? AppColors.accent;

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: buttonColor),
        label: TextSeed(
          text,
          color: buttonTextColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor),
          padding: padding ?? EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Espacement.radius),
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: buttonColor),
        padding: padding ?? EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
      ),
      child: TextSeed(
        text,
        color: buttonTextColor,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
      ),
    );
  }
}
