import 'package:flutter/material.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/input/input_field.dart';

class InputSearch extends StatelessWidget {
  const InputSearch({super.key, this.onChange, this.onPressed});
  final String? Function(String?)? onChange;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    final size = 14.0;
    return InputField(
      onChange: onChange,
      rightIcon: Container(
        padding: EdgeInsets.all(8.0),
        child: IconBoutton(
          svgPath: "assets/icon/filter.svg",
          size: size,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
