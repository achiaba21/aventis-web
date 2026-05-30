import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/kyc_status_resolver.dart';

/// Bandeau de statut KYC global affiché en tête de l'écran de vérification.
///
/// Fond + icône + libellés varient selon [status] (vérifié / en attente /
/// non vérifié).
class KycStatusHeader extends StatelessWidget {
  final KycGlobalStatus status;

  const KycStatusHeader({super.key, required this.status});

  Color get _bg {
    switch (status) {
      case KycGlobalStatus.verified:
        return AppColors.successLight;
      case KycGlobalStatus.pending:
        return AppColors.warningLight;
      case KycGlobalStatus.none:
        return AppColors.bgElev2;
    }
  }

  Color get _accent {
    switch (status) {
      case KycGlobalStatus.verified:
        return AppColors.success;
      case KycGlobalStatus.pending:
        return AppColors.warn;
      case KycGlobalStatus.none:
        return AppColors.text3;
    }
  }

  IconData get _icon {
    switch (status) {
      case KycGlobalStatus.verified:
        return Icons.verified_user;
      case KycGlobalStatus.pending:
        return Icons.hourglass_top;
      case KycGlobalStatus.none:
        return Icons.gpp_maybe;
    }
  }

  String get _title {
    switch (status) {
      case KycGlobalStatus.verified:
        return 'Identité vérifiée';
      case KycGlobalStatus.pending:
        return 'Vérification en cours';
      case KycGlobalStatus.none:
        return 'Identité non vérifiée';
    }
  }

  String get _subtitle {
    switch (status) {
      case KycGlobalStatus.verified:
        return 'Vous pouvez utiliser pleinement votre compte.';
      case KycGlobalStatus.pending:
        return 'Votre pièce est en cours de modération.';
      case KycGlobalStatus.none:
        return 'Envoyez une pièce d\'identité pour vérifier votre compte.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(_icon, size: 22, color: _accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.h3.copyWith(color: _accent),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
