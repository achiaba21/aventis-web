import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// État vide de la conversation
class ConversationEmptyState extends StatelessWidget {
  const ConversationEmptyState({
    super.key,
    required this.contactName,
    this.isNewConversation = false,
  });

  final String contactName;
  final bool isNewConversation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de message
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNewConversation
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.forum_outlined,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            TextSeed(
              isNewConversation
                  ? 'Nouvelle conversation'
                  : 'Aucun message',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            TextSeed(
              isNewConversation
                  ? 'Envoyez votre premier message\nà $contactName !'
                  : 'Commencez la conversation\navec $contactName',
              fontSize: 14,
              color: AppColors.textMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Suggestion
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  TextSeed(
                    'Dites bonjour !',
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de chargement pour les messages
class MessagesLoadingView extends StatelessWidget {
  const MessagesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          TextSeed(
            'Chargement des messages...',
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

/// Widget d'erreur pour les messages
class MessagesErrorView extends StatelessWidget {
  const MessagesErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            TextSeed(
              'Oups !',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            const SizedBox(height: 8),
            TextSeed(
              message,
              fontSize: 14,
              color: AppColors.textMuted,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
