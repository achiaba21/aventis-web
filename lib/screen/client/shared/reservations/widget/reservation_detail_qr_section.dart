import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section QR code — visible uniquement par le locataire à partir du statut
/// `payée`.
///
/// Container avec halo radial accent or (signature Asfar), QR sur fond blanc
/// pour lisibilité scanner, référence + sous-titre "Présentez ce code à
/// l'arrivée".
class ReservationDetailQrSection extends StatelessWidget {
  final String secretKey;
  final String reference;

  const ReservationDetailQrSection({
    super.key,
    required this.secretKey,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          radius: 0.9,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: QrImageView(
              data: secretKey,
              size: 220,
              backgroundColor: AppColors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reference,
            style: AppTextStyles.mono(AppTextStyles.h3),
          ),
          const SizedBox(height: 4),
          Text(
            "Présentez ce code à l'arrivée",
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}
