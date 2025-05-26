import 'package:flutter/material.dart';
import 'package:web_flutter/widget/input/input_field.dart';

class InputZone extends StatelessWidget {
  const InputZone({
    super.key,
    this.controller,
    this.placeHolder,
    this.onChange,
  });
  final String? placeHolder;
  final TextEditingController? controller;
  final String? Function(String?)? onChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InputField(
          keyboardType: TextInputType.multiline,
          placeHolder: placeHolder,
          controller: controller,
          onChange: onChange,
        ),
      ],
    );
  }
}
