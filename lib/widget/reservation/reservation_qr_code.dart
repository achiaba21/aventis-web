import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget réutilisable pour afficher un QR Code de réservation
/// Respecte le principe SRP (Single Responsibility Principle)
class ReservationQRCode extends StatelessWidget {
  const ReservationQRCode({
    super.key,
    required this.secretKey,
    this.size = 200.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String secretKey;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: secretKey,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor ?? AppColors.white,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor ?? AppColors.textPrimary,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
