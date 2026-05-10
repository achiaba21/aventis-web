import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cercle accent or 18×18 affichant le compteur unread d'une
/// `ConversationRow`.
class ConversationUnreadBadge extends StatelessWidget {
  final int count;

  const ConversationUnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
