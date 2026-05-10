import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card du solde disponible — Wallet screen démarcheur.
///
/// Reproduit fidèlement le proto `demarcheur.jsx::DemarcheurWallet`
/// (lignes 489-507) : gradient bleu-nuit 2 stops `[#1A2A4A, #0E1626]`,
/// border bleue translucide, padding 20, radius 22, montant 36 px,
/// texte info versement vendredi, bouton « Retirer maintenant » sur fond
/// translucide blanc.
class WalletSoldeCard extends StatelessWidget {
  final int amount;
  final String autoTransferText;
  final VoidCallback? onWithdraw;

  const WalletSoldeCard({
    super.key,
    required this.amount,
    this.autoTransferText =
        'Versement automatique tous les vendredis sur Orange Money',
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientBlueShort,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.walletBlueBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLDE DISPONIBLE',
            style: AppTextStyles.eyebrow.copyWith(
              color: AppColors.walletBlueAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            FcfaFormatter.full(amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: Colors.white,
            )),
          ),
          const SizedBox(height: 6),
          Text(
            autoTransferText,
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          _withdrawButton(context),
        ],
      ),
    );
  }

  Widget _withdrawButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onWithdraw,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
                'Retirer maintenant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
