import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';

/// Bouton secondary du design system Asfar Premium.
///
/// Reproduit `.btn-secondary` du prototype : fond `bgElev2`, border `line`,
/// texte clair, scale-on-press 0.97.
class OutlinedCustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool block;
  final bool loading;
  final IconData? leadingIcon;
  final Color? textColor;

  const OutlinedCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.block = false,
    this.loading = false,
    this.leadingIcon,
    this.textColor,
  });

  @override
  State<OutlinedCustomButton> createState() => _OutlinedCustomButtonState();
}

class _OutlinedCustomButtonState extends State<OutlinedCustomButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  @override
  Widget build(BuildContext context) {
    final color = widget.textColor ?? AppColors.text;
    final children = <Widget>[];
    if (widget.loading) {
      children.add(
        SizedBox(
          width: widget.size.fontSize + 4,
          height: widget.size.fontSize + 4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      );
    } else {
      if (widget.leadingIcon != null) {
        children.add(Icon(
          widget.leadingIcon,
          size: widget.size.fontSize + 2,
          color: color,
        ));
        children.add(const SizedBox(width: 8));
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
    }

    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 90),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.paddingX,
          vertical: widget.size.paddingY,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgElev2,
          borderRadius: BorderRadius.circular(widget.size.radius),
          border: Border.all(
            color: AppColors.line,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
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
