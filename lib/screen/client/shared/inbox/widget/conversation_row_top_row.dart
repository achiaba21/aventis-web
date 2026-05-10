import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Ligne du haut d'une `ConversationRow` : nom + (optionnel) shield certifié
/// + heure à droite.
class ConversationRowTopRow extends StatelessWidget {
  final String name;
  final bool certified;
  final String time;

  const ConversationRowTopRow({
    super.key,
    required this.name,
    required this.certified,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (certified) ...[
          const SizedBox(width: 6),
          const Icon(Icons.verified_user_outlined,
              size: 12, color: AppColors.accent),
        ],
        const Spacer(),
        Text(
          time,
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
