import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class InputZone extends StatelessWidget {
  const InputZone({
    super.key,
    this.controller,
    this.placeHolder,
    this.onChange,
    this.validator,
    this.libelle,
  });
  final String? placeHolder;
  final TextEditingController? controller;
  final String? Function(String?)? onChange;
  final String? Function(String?)? validator;
  final String? libelle;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Style.primaryColor,
        ),
      ),
      child: Column(
        spacing: Espacement.gapItem,
        children: [
          if (libelle != null) TextSeed(libelle),
          TextFormField(
            validator: validator,
            controller: controller,
            onChanged: onChange,
            keyboardType: TextInputType.multiline,
            maxLines: 25,
            minLines: 3,
            style: TextStyle(color: Style.containerColor2),
            //scrollPhysics: AlwaysScrollableScrollPhysics(),
            cursorColor: Style.primaryColor,
            decoration: InputDecoration(
              hintText: placeHolder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Espacement.radius),
                borderSide: BorderSide(color: Style.primaryColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Espacement.radius),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
