import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Carte d'une charge dans la liste.
///
/// Sémantique post-2026-05-13 : chaque charge = un paiement déjà enregistré.
/// Plus de swipe-to-pay, plus de badge statut.
class ChargeRow extends StatelessWidget {
  final Charge charge;
  final VoidCallback? onTap;

  const ChargeRow({
    super.key,
    required this.charge,
    this.onTap,
  });

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day} ${_months[dt.month - 1]}';
  }

  String _subLine() {
    final appart = charge.appartementNom?.trim();
    final pivot = charge.dateDebut ?? charge.createdAt;
    final dateText = pivot != null ? _formatDate(pivot) : '';
    if ((appart == null || appart.isEmpty) && dateText.isEmpty) return '';
    if (appart == null || appart.isEmpty) return dateText;
    if (dateText.isEmpty) return appart;
    return '$appart · $dateText';
  }

  @override
  Widget build(BuildContext context) {
    final montant = (charge.montant ?? 0).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            border: Border.all(color: AppColors.line, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              _ChargeTypeIcon(typeIcon: charge.typeCharge.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            charge.labelComplet,
                            style: AppTextStyles.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FcfaFormatter.full(montant),
                          style: AppTextStyles.mono(const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subLine(),
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChargeTypeIcon extends StatelessWidget {
  final String typeIcon;

  const _ChargeTypeIcon({required this.typeIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(typeIcon, style: const TextStyle(fontSize: 20)),
    );
  }
}
