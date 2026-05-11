import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Preview commission Asfar calculée à partir du prix/nuit — étape 5 wizard.
///
/// Reproduit `proprietaire-extras.jsx::step 5` preview (lignes 234-251) :
/// "Prix client (5 nuits) / Commission Asfar (8%) / Vous recevez".
class PricingCommissionPreview extends StatelessWidget {
  final int pricePerNight;

  const PricingCommissionPreview({
    super.key,
    required this.pricePerNight,
  });

  static const _previewNights = 5;
  static const _commissionRate = 0.08;

  @override
  Widget build(BuildContext context) {
    final int subtotal = pricePerNight * _previewNights;
    final int commission = (subtotal * _commissionRate).round();
    final int payout = subtotal - commission;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewRow(
            label: 'Prix client (5 nuits)',
            amount: FcfaFormatter.full(subtotal),
            labelColor: AppColors.text2,
            amountColor: AppColors.text,
          ),
          const SizedBox(height: 4),
          _PreviewRow(
            label: 'Commission Asfar (8%)',
            amount: '−${FcfaFormatter.full(commission)}',
            labelColor: AppColors.text2,
            amountColor: AppColors.text3,
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.line, width: 1),
              ),
            ),
            child: _PreviewRow(
              label: 'Vous recevez',
              amount: FcfaFormatter.full(payout),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              amountStyle: AppTextStyles.mono(const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color? labelColor;
  final Color? amountColor;
  final TextStyle? labelStyle;
  final TextStyle? amountStyle;

  const _PreviewRow({
    required this.label,
    required this.amount,
    this.labelColor,
    this.amountColor,
    this.labelStyle,
    this.amountStyle,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle ls = labelStyle ??
        AppTextStyles.small.copyWith(fontSize: 12, color: labelColor);
    final TextStyle ams = amountStyle ??
        AppTextStyles.mono(AppTextStyles.small.copyWith(
          fontSize: 12,
          color: amountColor,
        ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: ls),
        Text(amount, style: ams),
      ],
    );
  }
}
