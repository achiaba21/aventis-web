import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton « envoyer » circulaire 40×40 accent or — bouton trailing du
/// `ChatInputBar`. Désactivé visuellement (opacity 0.4) quand `enabled`
/// est false.
class ChatSendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const ChatSendButton({super.key, required this.enabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent,
            ),
            child: const Icon(
              Icons.send,
              size: 18,
              color: AppColors.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}
