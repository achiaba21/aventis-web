import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

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

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  TextEditingController? controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = widget.controller;
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
        TextFormField(
          controller: controller,
          onChanged: widget.onChange,
          validator: widget.validator,
          cursorColor: Style.primaryColor,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: TextStyle(color: Style.containerColor2),
          decoration: InputDecoration(
            icon: widget.leftIcon,
            suffixIcon: widget.rightIcon,

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Style.primaryColor),
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
      ],
    );
  }
}
