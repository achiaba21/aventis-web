import 'package:flutter/material.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Carte affichant un démarcheur partenaire du propriétaire
class DemarcheurItem extends StatelessWidget {
  final Demarcheur demarcheur;
  final VoidCallback? onUnlink;

  const DemarcheurItem({
    super.key,
    required this.demarcheur,
    this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: TextSeed(
                demarcheur.prenom?.isNotEmpty == true
                    ? demarcheur.prenom![0].toUpperCase()
                    : "D",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  demarcheur.fullName,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                if (demarcheur.telephone != null) ...[
                  const SizedBox(height: 4),
                  TextSeed(
                    demarcheur.telephone!,
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
          if (onUnlink != null)
            IconButton(
              onPressed: onUnlink,
              icon: const Icon(Icons.link_off_outlined),
              color: AppColors.error,
              tooltip: "Délier ce démarcheur",
            ),
        ],
      ),
    );
  }
}
