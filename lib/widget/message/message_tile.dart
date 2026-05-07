import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/locataire/inbox/conversation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/palettes/avatar_color_palette.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
    this.conversation, {
    super.key,
    required this.currentUserId,
  });

  final Conversation conversation;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final contact = _getContact();
    final contactName = contact?.fullName ?? 'Utilisateur';
    final message = conversation.lastMessage;
    final hasUnread = conversation.hasUnreadMessages;
    final isLastMessageFromMe = _isLastMessageFromCurrentUser();

    return InkWell(
      onTap: () => _openConversation(context, contactName),
      borderRadius: BorderRadius.circular(Espacement.radius),
      child: Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.accent.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          children: [
            // Avatar
            _Avatar(
              user: contact,
              hasUnread: hasUnread,
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1: Nom + Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextSeed(
                          contactName,
                          fontSize: 15,
                          fontWeight:
                              hasUnread ? FontWeight.bold : FontWeight.w500,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextSeed(
                        _formatRelativeTime(message?.createdAt),
                        fontSize: 12,
                        color: hasUnread
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Ligne 2: Message preview + Badge
                  Row(
                    children: [
                      Expanded(
                        child: _MessagePreview(
                          message: message?.contenu,
                          isFromMe: isLastMessageFromMe,
                          hasUnread: hasUnread,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        _UnreadIndicator(count: conversation.unreadCount ?? 0),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Récupère le contact (l'autre participant)
  User? _getContact() {
    if (conversation.proprietaire?.id == currentUserId) {
      return conversation.locataire;
    } else if (conversation.locataire?.id == currentUserId) {
      return conversation.proprietaire;
    }
    // Fallback: retourner le premier disponible
    return conversation.proprietaire ?? conversation.locataire;
  }

  /// Vérifie si le dernier message a été envoyé par l'utilisateur courant
  bool _isLastMessageFromCurrentUser() {
    final lastMsg = conversation.lastMessage;
    if (lastMsg?.expediteur?.id == null) return false;
    return lastMsg!.expediteur!.id == currentUserId;
  }

  /// Formate la date en temps relatif
  String _formatRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Maintenant';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day}/${date.month}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  void _openConversation(BuildContext context, String contactName) {
    if (conversation.id == null) return;

    final contact = _getContact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          conversationId: conversation.id!,
          contactName: contactName,
          currentUserId: currentUserId,
          contact: contact,
        ),
      ),
    );
  }
}

/// Avatar avec initiales en fallback
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.user,
    required this.hasUnread,
  });

  final User? user;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final hasImage = user?.imgUrl != null && user!.imgUrl!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAvatarColor(),
            border: hasUnread
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: hasImage
              ? ClipOval(
                  child: Image.network(
                    user!.imgUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _InitialsWidget(initials),
                  ),
                )
              : _InitialsWidget(initials),
        ),
        // Indicateur en ligne (optionnel, à activer si vous avez le statut)
        // Positioned(
        //   right: 2,
        //   bottom: 2,
        //   child: _OnlineIndicator(),
        // ),
      ],
    );
  }

  String _getInitials() {
    if (user == null) return '?';

    final nom = user!.nom ?? '';
    final prenom = user!.prenom ?? '';

    if (nom.isEmpty && prenom.isEmpty) return '?';

    final firstInitial = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    final secondInitial = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';

    return '$firstInitial$secondInitial'.trim();
  }

  Color _getAvatarColor() {
    // Générer une couleur basée sur le nom pour la consistance
    if (user?.id == null) return AppColors.textSecondary;
    return AvatarColorPalette.fromSeed(user!.id!);
  }
}

class _InitialsWidget extends StatelessWidget {
  const _InitialsWidget(this.initials);

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextSeed(
        initials,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnAccent,
      ),
    );
  }
}

/// Preview du message avec préfixe "Vous:"
class _MessagePreview extends StatelessWidget {
  const _MessagePreview({
    required this.message,
    required this.isFromMe,
    required this.hasUnread,
  });

  final String? message;
  final bool isFromMe;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (isFromMe)
            TextSpan(
              text: 'Vous: ',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          TextSpan(
            text: message ?? 'Aucun message',
            style: TextStyle(
              fontSize: 13,
              color: hasUnread ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Indicateur de messages non lus
class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextSeed(
          count > 99 ? '99+' : count.toString(),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnAccent,
        ),
      ),
    );
  }
}
