import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/bottom_nav/bottom_bar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// Bottom bar fixe du Detail logement : prix par nuit + dates + CTA Réserver.
class DetailBottomBar extends StatelessWidget {
  final int pricePerNight;
  final String dates;
  final VoidCallback? onReserve;

  const DetailBottomBar({
    super.key,
    required this.pricePerNight,
    required this.dates,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FcfaFormatter.compact(pricePerNight),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
              const SizedBox(height: 2),
              Text(
                'par nuit · $dates',
                style: AppTextStyles.small.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CustomButton(
              text: 'Réserver',
              onPressed: onReserve,
              size: ButtonSize.md,
              block: true,
            ),
          ),
        ],
      ),
    );
  }
}
