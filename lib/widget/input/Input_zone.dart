import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

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
          selectionColor: AppColors.accent,
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
            style: TextStyle(color: AppColors.background),
            //scrollPhysics: AlwaysScrollableScrollPhysics(),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: placeHolder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Espacement.radius),
                borderSide: BorderSide(color: AppColors.accent),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Espacement.radius),
                borderSide: BorderSide(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
