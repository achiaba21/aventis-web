import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.libelle,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.leftIcon,
    this.rightIcon,
    this.placeHolder,
    this.validator,
    this.inputFormatters,
    this.onChange,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
  });
  final String? libelle;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final String? placeHolder;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final bool enabled;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  TextEditingController? controller;
  String? initialValue;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    initialValue = widget.initialValue;
    if (controller != null && initialValue != null) {
      controller!.text = initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final libele = widget.libelle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (libele != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextSeed(libele),
          ),
        Theme(
          data: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: AppColors.accent,
            ),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: widget.controller == null ? initialValue : null,
            onChanged: widget.onChange,
            validator: widget.validator,
            cursorColor: AppColors.accent,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textInputAction: widget.textInputAction ??
                ((widget.keyboardType?.index == TextInputType.number.index ||
                        widget.keyboardType == TextInputType.phone)
                    ? TextInputAction.done
                    : null),
            onFieldSubmitted: widget.onFieldSubmitted,
            enabled: widget.enabled,
            style: TextStyle(color: AppColors.background),
            decoration: InputDecoration(
              icon: widget.leftIcon,
              suffixIcon: widget.rightIcon,

              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent),
                borderRadius: BorderRadius.circular(Espacement.radius),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Espacement.radius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Espacement.paddingInput,
                vertical: 0,
              ),
              hintText: widget.placeHolder,
            ),
            obscureText: widget.obscureText,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
          ),
        ),
      ],
    );
  }
}
