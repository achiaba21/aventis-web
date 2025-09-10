import 'package:flutter/material.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/input/input_field.dart';

class InputPass extends StatefulWidget {
  const InputPass({
    super.key,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.leftIcon,
    this.libelle,
    this.placeHolder,
    this.rightIcon,
    this.onchange,
  });

  final String? libelle;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final String? placeHolder;
  final String? Function(String? value)? onchange;

  @override
  State<InputPass> createState() => _InputPassState();
}

class _InputPassState extends State<InputPass> {
  bool hide = true;

  void toggle() {
    setState(() {
      hide = !hide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      controller: widget.controller,
      libelle: widget.libelle,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      obscureText: hide,
      onChange: widget.onchange,
      placeHolder: "pass",
      rightIcon: IconBoutton(
        onPressed: toggle,
        icon: hide ? Icons.remove_red_eye : Icons.hide_source,
      ),
    );
  }
}
