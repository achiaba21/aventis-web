import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/reservation/reservation_qr_code.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour afficher le code de réservation avec QR Code et informations
/// Respecte les principes OCP (Open/Closed) et DRY
class ReservationCodeCard extends StatelessWidget {
  const ReservationCodeCard({
    super.key,
    required this.codeReservation,
  });

  final CodeReservation codeReservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge de statut
        _buildStatusBadge(),
        Gap(Espacement.gapSection),

        // QR Code centré
        Center(
          child: ReservationQRCode(
            secretKey: codeReservation.secretKey ?? '',
            size: 220.0,
          ),
        ),
        Gap(Espacement.gapSection),

        // Message d'instruction
        Container(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Espacement.radius),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.accent,
                size: 20,
              ),
              Gap(Espacement.paddingInput),
              Expanded(
                child: TextSeed(
                  "Montrez ce code au propriétaire pour finaliser votre réservation",
                  fontSize: 13,
                  color: AppColors.border,
                ),
              ),
            ],
          ),
        ),
        Gap(Espacement.paddingBloc),

        // Informations du code
        _buildCodeInfo(),
      ],
    );
  }

  /// Badge de statut du code (valide, expiré, utilisé)
  Widget _buildStatusBadge() {
    Color statusColor;
    IconData statusIcon;
    String statusText = codeReservation.statusDescription;

    if (codeReservation.used == true) {
      statusColor = AppColors.inactive;
      statusIcon = Icons.check_circle;
    } else if (codeReservation.isExpired) {
      statusColor = AppColors.error;
      statusIcon = Icons.error;
    } else {
      statusColor = AppColors.success;
      statusIcon = Icons.verified;
    }

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: Espacement.paddingInput,
        ),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 18, color: AppColors.white),
            Gap(6),
            TextSeed(
              statusText,
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  /// Informations détaillées du code
  Widget _buildCodeInfo() {
    return Column(
      children: [
        // Date d'expiration
        if (codeReservation.expired != null)
          _buildInfoRow(
            Icons.schedule,
            "Expire le",
            formateDate(codeReservation.expired!, level: 2),
            isWarning: codeReservation.isExpired,
          ),
      ],
    );
  }

  /// Ligne d'information
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isWarning ? AppColors.error : AppColors.textMuted,
          ),
          Gap(8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSeed(
                  label,
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                TextSeed(
                  value,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? AppColors.error : AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
