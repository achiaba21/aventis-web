import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';

/// Bouton ghost du design system Asfar Premium.
///
/// Reproduit `.btn-ghost` du prototype : fond transparent, texte accent or
/// (par défaut), scale-on-press 0.97.
class PlainButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool block;
  final IconData? leadingIcon;
  final Color? textColor;

  const PlainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.block = false,
    this.leadingIcon,
    this.textColor,
  });

  @override
  State<PlainButton> createState() => _PlainButtonState();
}

class _PlainButtonState extends State<PlainButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final color = widget.textColor ?? AppColors.accent;
    final children = <Widget>[];
    if (widget.leadingIcon != null) {
      children.add(Icon(
        widget.leadingIcon,
        size: widget.size.fontSize + 2,
        color: color,
      ));
      children.add(const SizedBox(width: 6));
    }
    children.add(Text(
      widget.text,
      style: TextStyle(
        color: color,
        fontSize: widget.size.fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    ));

    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 90),
      // Pas d'alignment sur le Container : bug Flutter 3.35.2 + iOS 26 où
      // un Container avec alignment dans un parent loose (bottomNavigationBar,
      // Row+Expanded) expand à toute la hauteur dispo → bouton pleine page.
      // Aligné avec CustomButton + OutlinedCustomButton.
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.paddingX,
          vertical: widget.size.paddingY,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.size.radius),
        ),
        child: Row(
          mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );

    return Opacity(
      opacity: _disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTapDown: _disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: _disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel:
            _disabled ? null : () => setState(() => _pressed = false),
        onTap: _disabled ? null : widget.onPressed,
        child:
            widget.block ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }
}
