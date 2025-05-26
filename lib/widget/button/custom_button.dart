import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, this.text});
  final void Function()? onPressed;
  final String? text;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Style.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [TextSeed(text, color: Colors.white)],
      ),
    );
  }
}
