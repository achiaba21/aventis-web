import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';

/// Bouton primary du design system Asfar Premium.
///
/// Reproduit `.btn-primary` du prototype : fond accent or, texte sombre,
/// radius `md`, scale-on-press 0.97.
///
/// 3 tailles via [ButtonSize] · option [block] pour pleine largeur · [loading]
/// pour spinner inline · [leadingIcon] pour icône à gauche du texte.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool block;
  final bool loading;
  final IconData? leadingIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.block = false,
    this.loading = false,
    this.leadingIcon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.loading) {
      children.add(
        SizedBox(
          width: widget.size.fontSize + 4,
          height: widget.size.fontSize + 4,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.onAccent),
          ),
        ),
      );
    } else {
      if (widget.leadingIcon != null) {
        children.add(Icon(
          widget.leadingIcon,
          size: widget.size.fontSize + 2,
          color: AppColors.onAccent,
        ));
        children.add(const SizedBox(width: 8));
      }
      children.add(Flexible(
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onAccent,
            fontSize: widget.size.fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ));
    }

    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 90),
      // Pas d'alignment sur le Container : sous Flutter 3.35.2 + iOS 26.2,
      // alignment + parent loose (ex: Scaffold.bottomNavigationBar) fait
      // expand le Container à toute la hauteur dispo → CustomButton pleine
      // page. Le centrage est déjà assuré par mainAxisAlignment du Row.
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.paddingX,
          vertical: widget.size.paddingY,
        ),
        decoration: BoxDecoration(
          color: _disabled
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.accent,
          borderRadius: BorderRadius.circular(widget.size.radius),
        ),
        child: Row(
          mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: _disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: _disabled ? null : () => setState(() => _pressed = false),
      onTap: _disabled ? null : widget.onPressed,
      child: widget.block ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
