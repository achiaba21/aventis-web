import 'package:flutter/material.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/palettes/avatar_color_palette.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// AppBar personnalisée pour l'écran de conversation
class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConversationAppBar({
    super.key,
    required this.contactName,
    this.contact,
    this.isOnline = false,
    this.lastSeen,
    this.onBackPressed,
    this.onProfileTap,
  });

  final String contactName;
  final User? contact;
  final bool isOnline;
  final DateTime? lastSeen;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.textPrimary,
      ),
      titleSpacing: 0,
      title: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              // Avatar
              _ContactAvatar(contact: contact, isOnline: isOnline),
              const SizedBox(width: 12),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextSeed(
                      contactName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _StatusText(
                      isOnline: isOnline,
                      lastSeen: lastSeen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
          color: AppColors.background,
          onSelected: (value) {
            // Actions futures: bloquer, signaler, etc.
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 12),
                  TextSeed('Voir le profil', color: AppColors.textPrimary),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.notifications_off_outlined, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 12),
                  TextSeed('Mettre en sourdine', color: AppColors.textPrimary),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Avatar du contact avec indicateur en ligne
class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.contact,
    required this.isOnline,
  });

  final User? contact;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final hasImage = contact?.imgUrl != null && contact!.imgUrl!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAvatarColor(),
          ),
          child: hasImage
              ? ClipOval(
                  child: Image.network(
                    contact!.imgUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _InitialsWidget(initials),
                  ),
                )
              : _InitialsWidget(initials),
        ),
        // Indicateur en ligne
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  String _getInitials() {
    if (contact == null) return '?';

    final nom = contact!.nom ?? '';
    final prenom = contact!.prenom ?? '';

    if (nom.isEmpty && prenom.isEmpty) return '?';

    final firstInitial = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    final secondInitial = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';

    return '$firstInitial$secondInitial'.trim();
  }

  Color _getAvatarColor() {
    if (contact?.id == null) return AppColors.textSecondary;
    return AvatarColorPalette.fromSeed(contact!.id!);
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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnAccent,
      ),
    );
  }
}

/// Texte de statut (En ligne / Vu il y a...)
class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.isOnline,
    this.lastSeen,
  });

  final bool isOnline;
  final DateTime? lastSeen;

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          TextSeed(
            'En ligne',
            fontSize: 12,
            color: AppColors.success,
          ),
        ],
      );
    }

    final statusText = _formatLastSeen(lastSeen);
    return TextSeed(
      statusText,
      fontSize: 12,
      color: AppColors.textMuted,
    );
  }

  String _formatLastSeen(DateTime? date) {
    if (date == null) return 'Hors ligne';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 5) {
      return 'Vu à l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Vu il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Vu il y a ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Vu hier';
    } else if (diff.inDays < 7) {
      return 'Vu il y a ${diff.inDays} jours';
    } else {
      return 'Vu le ${date.day}/${date.month}';
    }
  }
}
