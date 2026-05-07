import 'package:flutter/material.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/palettes/avatar_color_palette.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Position du message dans un groupe
enum MessagePosition { single, first, middle, last }

class MessageItem extends StatelessWidget {
  const MessageItem(
    this.message, {
    super.key,
    this.isCurrentUser = false,
    this.position = MessagePosition.single,
    this.showAvatar = true,
    this.showTime = true,
  });

  final ChatMessage message;
  final bool isCurrentUser;
  final MessagePosition position;
  final bool showAvatar;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: _getTopPadding(),
        bottom: _getBottomPadding(),
      ),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar pour les messages reçus (seulement si dernier du groupe)
          if (!isCurrentUser) ...[
            if (showAvatar && (position == MessagePosition.single || position == MessagePosition.last))
              _MessageAvatar(user: message.expediteur)
            else
              const SizedBox(width: 32), // Espace réservé pour l'alignement
            const SizedBox(width: 8),
          ],

          // Bulle de message
          Flexible(
            child: _MessageBubble(
              message: message,
              isCurrentUser: isCurrentUser,
              position: position,
              showTime: showTime,
            ),
          ),

          // Espace à droite pour les messages envoyés
          if (isCurrentUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  double _getTopPadding() {
    switch (position) {
      case MessagePosition.single:
      case MessagePosition.first:
        return 4;
      case MessagePosition.middle:
      case MessagePosition.last:
        return 1;
    }
  }

  double _getBottomPadding() {
    switch (position) {
      case MessagePosition.single:
      case MessagePosition.last:
        return 4;
      case MessagePosition.first:
      case MessagePosition.middle:
        return 1;
    }
  }
}

/// Avatar du message
class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final hasImage = user?.imgUrl != null && user!.imgUrl!.isNotEmpty;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                user!.imgUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(initials),
              ),
            )
          : _buildInitials(initials),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: TextSeed(
        initials,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnAccent,
      ),
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
    if (user?.id == null) return AppColors.textSecondary;
    return AvatarColorPalette.fromSeed(user!.id!);
  }
}

/// Bulle de message
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.position,
    required this.showTime,
  });

  final ChatMessage message;
  final bool isCurrentUser;
  final MessagePosition position;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accent
            : AppColors.surface,
        borderRadius: _getBorderRadius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenu du message
          TextSeed(
            message.contenu ?? '',
            fontSize: 14,
            color: isCurrentUser
                ? AppColors.textOnAccent
                : AppColors.textPrimary,
          ),

          // Heure et statut (seulement si showTime ou dernier message du groupe)
          if (showTime || position == MessagePosition.single || position == MessagePosition.last) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextSeed(
                  message.timeDisplay,
                  fontSize: 10,
                  color: isCurrentUser
                      ? AppColors.textOnAccent.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 4),
                  _SendingStatus(message: message, isCurrentUser: isCurrentUser),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    const double radius = 18;
    const double smallRadius = 4;

    if (isCurrentUser) {
      // Messages envoyés (à droite)
      switch (position) {
        case MessagePosition.single:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(smallRadius),
          );
        case MessagePosition.first:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(smallRadius),
          );
        case MessagePosition.middle:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(smallRadius),
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(smallRadius),
          );
        case MessagePosition.last:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(smallRadius),
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
      }
    } else {
      // Messages reçus (à gauche)
      switch (position) {
        case MessagePosition.single:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(smallRadius),
            bottomRight: Radius.circular(radius),
          );
        case MessagePosition.first:
          return const BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(smallRadius),
            bottomRight: Radius.circular(radius),
          );
        case MessagePosition.middle:
          return const BorderRadius.only(
            topLeft: Radius.circular(smallRadius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(smallRadius),
            bottomRight: Radius.circular(radius),
          );
        case MessagePosition.last:
          return const BorderRadius.only(
            topLeft: Radius.circular(smallRadius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
      }
    }
  }
}

/// Indicateur d'état d'envoi
class _SendingStatus extends StatelessWidget {
  const _SendingStatus({
    required this.message,
    required this.isCurrentUser,
  });

  final ChatMessage message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.textOnAccent.withValues(alpha: 0.7);

    if (message.isSending == true) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation(iconColor),
        ),
      );
    }

    if (message.hasFailed == true) {
      return const Icon(
        Icons.error_outline,
        size: 14,
        color: AppColors.error,
      );
    }

    // Message envoyé avec succès
    return Icon(
      message.isRead == true ? Icons.done_all : Icons.done,
      size: 14,
      color: message.isRead == true
          ? AppColors.info
          : iconColor,
    );
  }
}

/// Séparateur de date entre les messages
class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextSeed(
                _formatDate(date),
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Aujourd'hui";
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else if (now.difference(date).inDays < 7) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }
}
