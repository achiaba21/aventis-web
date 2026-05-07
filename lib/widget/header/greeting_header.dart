import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.buttonText,
    required this.onButtonPressed,
  });

  final String userName;
  final String buttonText;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: TextSeed(
            "Hi, $userName",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        ElevatedButton.icon(
          onPressed: onButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Espacement.radius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Espacement.paddingInput,
              vertical: Espacement.paddingInput,
            ),
          ),
          icon: Icon(Icons.add, color: AppColors.white, size: 18),
          label: TextSeed(
            buttonText,
            color: AppColors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}